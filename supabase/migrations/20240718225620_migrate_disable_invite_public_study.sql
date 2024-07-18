-- Migrate policy
-- Drop existing policy

DROP POLICY "Editors can do everything with study invite codes" ON public.study_invite;

-- Create new policy
-- Editors can do everything with study invite codes if participation is invite
CREATE POLICY "Editors can do everything with study invite codes if participation is invite" ON public.study_invite USING (( SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study
  WHERE (study.id = study_invite.study_id AND study.participation = 'invite'::public.participation)));