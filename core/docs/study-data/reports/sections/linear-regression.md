# Linear Regression Section


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `linear_regression`. |
| `id` | `String` | Yes | - | Unique section identifier (UUID). |
| `title` | `String?` | No | - | Display title of this report section. |
| `description` | `String?` | No | - | Optional description. |
| `resultProperty` | `DataReference<num>?` | No | - | Reference to the numeric result property being analyzed. |
| `alpha` | `double` | No | `0.05` | Significance threshold for the regression (default 0.05). |
| `improvement` | `ImprovementDirection?` | No | - | Whether higher values represent improvement (`true`) or decline (`false`). |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `linearRegression` |
<!-- GENERATED:DISCRIMINATORS END -->
