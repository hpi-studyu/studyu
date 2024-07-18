-- Migrate policy
-- DROP POLICY "Editors can do everything with their studies"

DROP POLICY "Editors can do everything with study invite codes" ON public.study;

-- CREATE POLICY where only the owner can edit the study if participation is invite
CREATE POLICY "Editors can do everything with study invite codes if participation is invite" ON public.study_invite USING (( SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study
  WHERE (study.id = study_invite.study_id AND study.participation = 'invite'::public.participation)));