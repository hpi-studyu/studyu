-- begin the transaction, allows to rollback any changes made during the test
BEGIN;

--
-- seed
--

-- TODO create variables
select tests.create_supabase_user('test_creator_1', 'test_creator_1@studyu.health');
select tests.create_supabase_user('test_creator_2', 'test_creator_2@studyu.health');
select tests.create_supabase_user('test_consumer', 'test_consumer@studyu.health');

INSERT INTO public.app_config (id, app_min_version, app_privacy, app_terms, designer_privacy, designer_terms, imprint, contact, analytics)
VALUES (
    'prod',
    '2.6.0',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "email": "email@example.com", "phone": "1235678", "website": "example.com", "organization": "example" }',
    '{ "dsn": "example", "enabled": false, "samplingRate": 0 }'
);

--
-- Creator 1
-- Description: Studies should be visible to consumer
--

INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=true, registry_published=true, participation=open, result_sharing=public',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  true,
  -- registry_published
  true,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_1') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'open',
  -- result_sharing ('public', 'organization', 'private')
  'public',
  '{}'
);

INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=true, registry_published=false, participation=open, result_sharing=public',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  true,
  -- registry_published
  false,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_1') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'open',
  -- result_sharing ('public', 'organization', 'private')
  'public',
  '{}'
);

INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=true, registry_published=false, participation=invite, result_sharing=public',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  true,
  -- registry_published
  false,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_1') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'invite',
  -- result_sharing ('public', 'organization', 'private')
  'public',
  '{}'
);

-- only accessible with invite
INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=true, registry_published=false, participation=invite, result_sharing=private',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  true,
  -- registry_published
  false,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_1') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'invite',
  -- result_sharing ('public', 'organization', 'private')
  'private',
  '{}'
);

--
-- Creator 2
-- Description: Studies should not be visible to consumer
--

INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=false, registry_published=true, participation=open, result_sharing=public',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  false,
  -- registry_published
  true,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_2') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'open',
  -- result_sharing ('public', 'organization', 'private')
  'public',
  '{}'
);

INSERT INTO public.study (
  contact,
  title,
  description,
  icon_name,
  published,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  created_at,
  updated_at,
  user_id,
  participation,
  result_sharing,
  collaborator_emails
) VALUES(
  '{"email":"example@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"This study has not been submitted to the IRB Board. It is for illustration purposes of StudyU only.","institutionalReviewBoardNumber":"N/A"}',
  'Study: published=false, registry_published=false, participation=invite, result_sharing=private',
  'This is a Demo Study. This study helps you find out which treatment is more effective for you.',
  'accountHeart',
  -- published
  false,
  -- registry_published
  false,
  '[{"id": "recent_back_pain", "type": "boolean", "prompt": "Have you had back pain in the last 12 weeks?", "rationale": ""}, {"id": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "type": "boolean", "prompt": "Are you pregnant?", "rationale": ""}, {"id": "afeac253-4bfe-47fe-9384-4236ded1bd50", "type": "choice", "prompt": "Does any of the following apply to you and has not been examined by a doctor yet?", "choices": [{"id": "start_of_symptoms_after_spinal_surgery", "text": "Start of symptoms after spinal surgery"}, {"id": "start_of_symptoms_after_diagnosis_of_cancer", "text": "Start of symptoms after diagnosis of cancer"}, {"id": "unexpected_significant_weight_loss", "text": "Unexpected significant weight loss"}, {"id": "start_of_symptoms_after_trauma", "text": "Start of symptoms after trauma"}, {"id": "accompanying_numbness_of_your_legs", "text": "Accompanying numbness of your legs"}], "multiple": true, "rationale": "This question is asked to ensure that you are not suffering from any critical illness."}]','[{"id": "b47d07d8-eb98-4fce-86ab-945bc7c2f2d0", "condition": {"type": "choice", "target": "recent_back_pain", "choices": [true]}}, {"id": "acb368b0-0ca2-496d-98e1-be9fefbe5e89", "condition": {"type": "choice", "target": "f70386c8-f517-4e62-a5fa-ca4badfd4b60", "choices": [false]}}, {"id": "d7c3445e-b5b1-43d1-93a6-5637e0cfd44f", "condition": {"type": "choice", "target": "afeac253-4bfe-47fe-9384-4236ded1bd50", "choices": []}}]','[{"id": "rate_your_day", "type": "questionnaire", "title": "Rate your day", "footer": "", "header": "", "schedule": {"reminders": ["19:00"], "completionPeriods": [{"id": "50d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "8:00"}]}, "questions": [{"id": "pain", "step": 1, "type": "visualAnalogue", "prompt": "Rate your pain.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "Well, guess I die now", "minimumAnnotation": "no pain"}, {"id": "painkillers", "type": "boolean", "prompt": "Have you taken any painkillers in the last 24 hours?"}, {"id": "sleep", "step": 1, "type": "visualAnalogue", "prompt": "Rate your sleep.", "initial": 0, "maximum": 10, "minimum": 0, "maximumColor": 4294901760, "minimumColor": 4294967295, "maximumAnnotation": "terrible", "minimumAnnotation": "no problems"}, {"id": "mood", "step": 1, "type": "annotatedScale", "prompt": "Rate your mood.", "initial": 5, "maximum": 10, "minimum": 0, "annotations": [{"value": 0, "annotation": "☠"}, {"value": 5, "annotation": "😐"}, {"value": 10, "annotation": "😀"}]}]}]','[{"id": "willow_bark_tea", "icon": "coffee", "name": "Willow-Bark tea", "tasks": [{"id": "drink_tea", "type": "checkmark", "title": "Drink a cup of Willow-Bark tea twice a day.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "54d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Willow bark contains powerful anti-inflamatory compunds such as flavonoids and salicin that help relieve the pain."}, {"id": "arnika", "icon": "leaf", "name": "Arnika", "tasks": [{"id": "apply_arnika", "type": "checkmark", "title": "Apply a dime sized amount of Arnica gel to your lower back and massage for 10 mins.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "55d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Arnika gel has been proven to soothe muscle soreness, strain and reduce swelling when rubbed on the affected area."}, {"id": "warming_pad", "icon": "car-seat-heater", "name": "Warming Pad", "tasks": [{"id": "use_pad", "type": "checkmark", "title": "Apply warming pad to your lower back for 5 minutes.", "schedule": {"reminders": ["18:00"], "completionPeriods": [{"id": "56d114f3-e692-4283-9610-17e23edf8f70", "lockTime": "20:00", "unlockTime": "6:00"}]}}], "description": "Applying a warming pad is a quick and easy way to soothe sore muscles and joints."}]','[{"id": "Need", "title": "Why Consent Is Needed", "iconName": "featureSearch", "description": "We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary."}, {"id": "Risk_benefit", "title": "Risks & Benefits", "iconName": "signCaution", "description": "The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you."}, {"id": "Data", "title": "Data Handling & Use", "iconName": "databaseExport", "description": "By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis."}, {"id": "Issues", "title": "Issues to Consider", "iconName": "mapClock", "description": "For being able to use your results for research we need you to actively participate for the indicated minimum study duration. After reaching this you will be able to unlock results but we encourage you to take part at least until you reach the recommended level on the progress bar. Otherwise it might be the case that results can indeed be used for research but are not meaningful for you personally. Note that if you decide to take part in this research study you will be responsible for buying the needed aids."}, {"id": "Rights", "title": "Participant Rights", "iconName": "gavel", "description": "You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard."}, {"id": "Future", "title": "Future Research", "iconName": "binoculars", "description": "The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention."}]','{"sequence": "alternating", "phaseDuration": 7, "numberOfCycles": 2, "sequenceCustom": "ABAB", "includeBaseline": true}','{"primary": {"id": "average", "type": "average", "title": "Average", "aggregate": "day", "description": "Average", "resultProperty": {"task": "rate_your_day", "property": "pain"}}, "secondary": []}',
  '[]',
  '2021-04-13 18:19:49.000',
  '2023-05-11 12:46:06.018',
  -- user_id
  (tests.get_supabase_user('test_creator_2') ->> 'id')::uuid,
  -- participation ('open', 'invite')
  'invite',
  -- result_sharing ('public', 'organization', 'private')
  'private',
  '{}'
);

--
-- start tests
--

-- plan tests in advance, this ensures the proper number of tests have been run.
SELECT plan(19);

-- UNRESTRICTED TESTS

SELECT is(count(*)::int, 1, 'Check if app_config was seeded') FROM public.app_config;

-- check if RLS is enabled on all tables in the public schema
SELECT tests.rls_enabled('public');

SELECT is(count(*)::int, 3, 'Check if users were created and can be accessed') FROM public.user;

-- ANONYMOUS TESTS

SELECT tests.clear_authentication();
SELECT is(count(*)::int, 0, 'Check if users cannot be accessed anonymously') FROM public.user;
SELECT is(published, true, 'Check if all anonymously accessed studies are published') FROM public.study;

-- CREATOR 1 TESTS

SELECT tests.authenticate_as('test_creator_1');
SELECT is(email, 'test_creator_1@studyu.health', 'Check if a user can only retrieve his user') FROM public.user;

-- CREATOR 2 TESTS

SELECT tests.authenticate_as('test_creator_2');
SELECT is(email, 'test_creator_2@studyu.health', 'Check if a user can only retrieve his user') FROM public.user;

-- CONSUMER TESTS

SELECT tests.authenticate_as('test_consumer');

-- test specific: all published studies are created by test_creator_1
SELECT is(user_id, (tests.get_supabase_user('test_creator_1') ->> 'id')::uuid, 'All published studies are created by test_creator_1') FROM public.study;
SELECT is(count(*)::int, 3, 'Verify number of accessible studies') FROM public.study;

-- check if the consumer can only access designated published studies
SELECT is(published, true, 'Check if test_consumer can only access studies that are published') FROM public.study;
SELECT tests.is_either_true(
      'Check if test_consumer can only retrieve designated studies',
      tests.is_equal(registry_published, true),
      tests.is_equal(participation, 'open'::public.participation),
      tests.is_equal(result_sharing, 'public'::public.result_sharing)
  )
  FROM
    public.study;

-- check the results of your test
select * from finish();

-- rollback the transaction, completing the test scenario
ROLLBACK;
