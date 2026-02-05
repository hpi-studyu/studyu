import { createClient } from '@supabase/supabase-js';
import { corsHeaders, handleCors } from '../_shared/cors.ts';

// Types
interface MealContext {
  mealType?: string;
  mealTime?: string;
}

interface NutritionData {
  energyKcal: number;
  protein: number;
  carbs: number;
  fat: number;
  sugars?: number;
  fiber?: number;
  saturatedFat?: number;
  sodium?: number;
}

interface AnalyzedFoodItem {
  name: string;
  description?: string;
  amount: number;
  unit: string;
  servingSizeGrams: number;
  nutrition: NutritionData;
  portionReference?: string;
  confidenceScore: number;
}

interface FoodAnalysisResponse {
  items: AnalyzedFoodItem[];
  overallConfidence: number;
  notes?: string;
}

interface LLMProvider {
  analyzeImage(imageBase64: string, mealContext?: MealContext): Promise<FoodAnalysisResponse>;
}

// System prompt for food analysis
const SYSTEM_PROMPT = `Analyze this food image and identify ALL distinct food items visible.
Return a JSON object with:
{
  "items": [
    {
      "name": "Descriptive food name",
      "description": "Brief description of this item",
      "amount": estimated_numeric_amount,
      "unit": "serving|cup|oz|g|piece|slice",
      "servingSizeGrams": estimated_grams,
      "nutrition": {
        "energyKcal": estimated_calories,
        "protein": estimated_grams,
        "carbs": estimated_grams,
        "fat": estimated_grams,
        "sugars": estimated_grams,
        "fiber": estimated_grams,
        "saturatedFat": estimated_grams,
        "sodium": estimated_mg
      },
      "portionReference": "visual cue (e.g., 'fist-sized', 'palm-sized')",
      "confidenceScore": 0.0_to_1.0
    }
  ],
  "overallConfidence": 0.0_to_1.0,
  "notes": "Any relevant context (e.g., 'appears to be homemade', 'restaurant portion')"
}
Guidelines:
- Identify each distinct food separately (e.g., "burger" and "fries" as separate items)
- If a complete meal, estimate each component
- Be realistic about uncertainty - use lower confidence for ambiguous items
- Include visible drinks as separate items if clearly identifiable
- All numeric values should be reasonable estimates based on typical portion sizes
- Use standard units: 'serving', 'cup', 'oz', 'g', 'piece', 'slice', 'tbsp', 'tsp'`;

// OpenAI Provider Implementation
class OpenAIProvider implements LLMProvider {
  private apiKey: string;
  private model: string;

  constructor(apiKey: string, model = 'gpt-4o-mini') {
    this.apiKey = apiKey;
    this.model = model;
  }

  async analyzeImage(imageBase64: string, mealContext?: MealContext): Promise<FoodAnalysisResponse> {
    const userContent = this.buildUserContent(mealContext);

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: this.model,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: userContent },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${imageBase64}`,
                },
              },
            ],
          },
        ],
        response_format: { type: 'json_object' },
        max_tokens: 2000,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content;

    if (!content) {
      throw new Error('Empty response from OpenAI');
    }

    return this.parseResponse(content);
  }

  private buildUserContent(mealContext?: MealContext): string {
    let content = 'Please analyze this food image and provide detailed nutritional estimates.';

    if (mealContext?.mealType) {
      content += ` This appears to be a ${mealContext.mealType}.`;
    }

    if (mealContext?.mealTime) {
      content += ` The meal time is ${mealContext.mealTime}.`;
    }

    return content;
  }

  private parseResponse(content: string): FoodAnalysisResponse {
    try {
      const parsed = JSON.parse(content);

      // Validate structure
      if (!parsed.items || !Array.isArray(parsed.items)) {
        throw new Error('Invalid response structure: missing items array');
      }

      // Validate and normalize each item
      const items: AnalyzedFoodItem[] = parsed.items.map((item: unknown) => this.validateAndNormalizeItem(item));

      return {
        items,
        overallConfidence: parsed.overallConfidence ?? 0.5,
        notes: parsed.notes,
      };
    } catch (error) {
      throw new Error(`Failed to parse LLM response: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private validateAndNormalizeItem(item: unknown): AnalyzedFoodItem {
    if (typeof item !== 'object' || item === null) {
      throw new Error('Invalid item: not an object');
    }

    const raw = item as Record<string, unknown>;

    return {
      name: String(raw.name ?? 'Unknown Food'),
      description: raw.description ? String(raw.description) : undefined,
      amount: Number(raw.amount) || 1,
      unit: String(raw.unit ?? 'serving'),
      servingSizeGrams: Number(raw.servingSizeGrams) || 100,
      nutrition: this.validateAndNormalizeNutrition(raw.nutrition),
      portionReference: raw.portionReference ? String(raw.portionReference) : undefined,
      confidenceScore: Math.max(0, Math.min(1, Number(raw.confidenceScore) || 0.5)),
    };
  }

  private validateAndNormalizeNutrition(nutrition: unknown): NutritionData {
    if (typeof nutrition !== 'object' || nutrition === null) {
      return {
        energyKcal: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugars: 0,
        fiber: 0,
        saturatedFat: 0,
        sodium: 0,
      };
    }

    const raw = nutrition as Record<string, unknown>;

    return {
      energyKcal: Number(raw.energyKcal) || 0,
      protein: Number(raw.protein) || 0,
      carbs: Number(raw.carbs) || 0,
      fat: Number(raw.fat) || 0,
      sugars: Number(raw.sugars) || 0,
      fiber: Number(raw.fiber) || 0,
      saturatedFat: Number(raw.saturatedFat) || 0,
      sodium: Number(raw.sodium) || 0,
    };
  }
}

// Anthropic Provider Implementation
class AnthropicProvider implements LLMProvider {
  private apiKey: string;
  private model: string;

  constructor(apiKey: string, model = 'claude-3-5-sonnet-20241022') {
    this.apiKey = apiKey;
    this.model = model;
  }

  async analyzeImage(imageBase64: string, mealContext?: MealContext): Promise<FoodAnalysisResponse> {
    const userContent = this.buildUserContent(mealContext);

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: this.model,
        max_tokens: 2000,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: userContent },
              {
                type: 'image',
                source: {
                  type: 'base64',
                  media_type: 'image/jpeg',
                  data: imageBase64,
                },
              },
            ],
          },
        ],
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Anthropic API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    const content = data.content?.[0]?.text;

    if (!content) {
      throw new Error('Empty response from Anthropic');
    }

    // Extract JSON from the response (Claude might wrap it in markdown)
    const jsonMatch = content.match(/```json\n?([\s\S]*?)\n?```/) ||
      content.match(/```\n?([\s\S]*?)\n?```/) ||
      [null, content];

    const jsonContent = jsonMatch[1] || content;
    return this.parseResponse(jsonContent);
  }

  private buildUserContent(mealContext?: MealContext): string {
    let content = 'Please analyze this food image and provide detailed nutritional estimates.';

    if (mealContext?.mealType) {
      content += ` This appears to be a ${mealContext.mealType}.`;
    }

    if (mealContext?.mealTime) {
      content += ` The meal time is ${mealContext.mealTime}.`;
    }

    return content;
  }

  private parseResponse(content: string): FoodAnalysisResponse {
    try {
      const parsed = JSON.parse(content);

      if (!parsed.items || !Array.isArray(parsed.items)) {
        throw new Error('Invalid response structure: missing items array');
      }

      const items: AnalyzedFoodItem[] = parsed.items.map((item: unknown) => this.validateAndNormalizeItem(item));

      return {
        items,
        overallConfidence: parsed.overallConfidence ?? 0.5,
        notes: parsed.notes,
      };
    } catch (error) {
      throw new Error(`Failed to parse LLM response: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private validateAndNormalizeItem(item: unknown): AnalyzedFoodItem {
    if (typeof item !== 'object' || item === null) {
      throw new Error('Invalid item: not an object');
    }

    const raw = item as Record<string, unknown>;

    return {
      name: String(raw.name ?? 'Unknown Food'),
      description: raw.description ? String(raw.description) : undefined,
      amount: Number(raw.amount) || 1,
      unit: String(raw.unit ?? 'serving'),
      servingSizeGrams: Number(raw.servingSizeGrams) || 100,
      nutrition: this.validateAndNormalizeNutrition(raw.nutrition),
      portionReference: raw.portionReference ? String(raw.portionReference) : undefined,
      confidenceScore: Math.max(0, Math.min(1, Number(raw.confidenceScore) || 0.5)),
    };
  }

  private validateAndNormalizeNutrition(nutrition: unknown): NutritionData {
    if (typeof nutrition !== 'object' || nutrition === null) {
      return {
        energyKcal: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugars: 0,
        fiber: 0,
        saturatedFat: 0,
        sodium: 0,
      };
    }

    const raw = nutrition as Record<string, unknown>;

    return {
      energyKcal: Number(raw.energyKcal) || 0,
      protein: Number(raw.protein) || 0,
      carbs: Number(raw.carbs) || 0,
      fat: Number(raw.fat) || 0,
      sugars: Number(raw.sugars) || 0,
      fiber: Number(raw.fiber) || 0,
      saturatedFat: Number(raw.saturatedFat) || 0,
      sodium: Number(raw.sodium) || 0,
    };
  }
}

// Gemini Provider Implementation
class GeminiProvider implements LLMProvider {
  private apiKey: string;
  private model: string;

  constructor(apiKey: string, model = 'gemini-2.0-flash') {
    this.apiKey = apiKey;
    this.model = model;
  }

  async analyzeImage(imageBase64: string, mealContext?: MealContext): Promise<FoodAnalysisResponse> {
    const userContent = this.buildUserContent(mealContext);

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { text: `${SYSTEM_PROMPT}\n\n${userContent}` },
                {
                  inlineData: {
                    mimeType: 'image/jpeg',
                    data: imageBase64,
                  },
                },
              ],
            },
          ],
          generationConfig: {
            responseMimeType: 'application/json',
            maxOutputTokens: 2000,
          },
        }),
      },
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Gemini API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!content) {
      throw new Error('Empty response from Gemini');
    }

    return this.parseResponse(content);
  }

  private buildUserContent(mealContext?: MealContext): string {
    let content = 'Please analyze this food image and provide detailed nutritional estimates.';

    if (mealContext?.mealType) {
      content += ` This appears to be a ${mealContext.mealType}.`;
    }

    if (mealContext?.mealTime) {
      content += ` The meal time is ${mealContext.mealTime}.`;
    }

    return content;
  }

  private parseResponse(content: string): FoodAnalysisResponse {
    try {
      const parsed = JSON.parse(content);

      if (!parsed.items || !Array.isArray(parsed.items)) {
        throw new Error('Invalid response structure: missing items array');
      }

      const items: AnalyzedFoodItem[] = parsed.items.map((item: unknown) => this.validateAndNormalizeItem(item));

      return {
        items,
        overallConfidence: parsed.overallConfidence ?? 0.5,
        notes: parsed.notes,
      };
    } catch (error) {
      throw new Error(`Failed to parse LLM response: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private validateAndNormalizeItem(item: unknown): AnalyzedFoodItem {
    if (typeof item !== 'object' || item === null) {
      throw new Error('Invalid item: not an object');
    }

    const raw = item as Record<string, unknown>;

    return {
      name: String(raw.name ?? 'Unknown Food'),
      description: raw.description ? String(raw.description) : undefined,
      amount: Number(raw.amount) || 1,
      unit: String(raw.unit ?? 'serving'),
      servingSizeGrams: Number(raw.servingSizeGrams) || 100,
      nutrition: this.validateAndNormalizeNutrition(raw.nutrition),
      portionReference: raw.portionReference ? String(raw.portionReference) : undefined,
      confidenceScore: Math.max(0, Math.min(1, Number(raw.confidenceScore) || 0.5)),
    };
  }

  private validateAndNormalizeNutrition(nutrition: unknown): NutritionData {
    if (typeof nutrition !== 'object' || nutrition === null) {
      return {
        energyKcal: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugars: 0,
        fiber: 0,
        saturatedFat: 0,
        sodium: 0,
      };
    }

    const raw = nutrition as Record<string, unknown>;

    return {
      energyKcal: Number(raw.energyKcal) || 0,
      protein: Number(raw.protein) || 0,
      carbs: Number(raw.carbs) || 0,
      fat: Number(raw.fat) || 0,
      sugars: Number(raw.sugars) || 0,
      fiber: Number(raw.fiber) || 0,
      saturatedFat: Number(raw.saturatedFat) || 0,
      sodium: Number(raw.sodium) || 0,
    };
  }
}

// Provider factory
function createProvider(): LLMProvider {
  const provider = Deno.env.get('LLM_PROVIDER')?.toLowerCase() || 'openai';

  switch (provider) {
    case 'openai': {
      const apiKey = Deno.env.get('OPENAI_API_KEY');
      if (!apiKey) {
        throw new Error('OPENAI_API_KEY not configured');
      }
      const model = Deno.env.get('OPENAI_MODEL') || 'gpt-4o-mini';
      return new OpenAIProvider(apiKey, model);
    }
    case 'anthropic': {
      const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
      if (!apiKey) {
        throw new Error('ANTHROPIC_API_KEY not configured');
      }
      const model = Deno.env.get('ANTHROPIC_MODEL') || 'claude-3-5-sonnet-20241022';
      return new AnthropicProvider(apiKey, model);
    }
    case 'gemini': {
      const apiKey = Deno.env.get('GOOGLE_API_KEY');
      if (!apiKey) {
        throw new Error('GOOGLE_API_KEY not configured');
      }
      const model = Deno.env.get('GEMINI_MODEL') || 'gemini-2.0-flash';
      return new GeminiProvider(apiKey, model);
    }
    default:
      throw new Error(`Unknown LLM provider: ${provider}`);
  }
}

// Main handler
Deno.serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Verify authorization
    const authHeader = req.headers.get('authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Parse request body
    let body: { imageBase64?: string; mealType?: string; mealTime?: string };
    try {
      body = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ error: 'Invalid JSON body' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Validate image data
    if (!body.imageBase64 || typeof body.imageBase64 !== 'string') {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid imageBase64 field' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Validate base64 data (basic check)
    const base64Data = body.imageBase64.trim();
    if (base64Data.length < 100) {
      return new Response(
        JSON.stringify({ error: 'Image data too small or invalid' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Create provider and analyze
    const provider = createProvider();
    const mealContext: MealContext = {
      mealType: body.mealType,
      mealTime: body.mealTime,
    };

    const result = await provider.analyzeImage(base64Data, mealContext);

    // Return successful response
    return new Response(
      JSON.stringify({
        success: true,
        data: result,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('Error analyzing food image:', error);

    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
