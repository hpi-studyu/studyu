BEGIN;

/*
 * This function implements account recovery for users who have lost access to their account.
 * It takes a user ID, generates a new password, finds their latest active study, and returns
 * the credentials needed to log back in.
 *
 * @param p_user_id - The UUID of the user to recover (decoded from 13-word recovery phrase)
 *
 * @returns jsonb - {
 *   "success": true/false,
 *   "email": "user-email@domain.com",
 *   "password": "newly-generated-password",
 *   "subject_id": "study-subject-uuid-or-null",
 *   "error": "error-message-if-failed"
 * }
 */
CREATE OR REPLACE FUNCTION public.recover_account(
    p_user_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_user_email text;
    v_new_password text;
    v_encrypted_password text;
    v_subject_id uuid;
    v_latest_progress_date timestamptz;
BEGIN
    -- 1. Validate user exists in auth.users
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = p_user_id;

    IF v_user_email IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;

    -- 2. Generate new random password
    v_new_password := gen_random_uuid()::text;
    v_encrypted_password := extensions.crypt(v_new_password, extensions.gen_salt('bf', 12));

    -- 3. Update user's password in auth.users
    UPDATE auth.users
    SET
        encrypted_password = v_encrypted_password,
        updated_at = now() at time zone 'utc'
    WHERE id = p_user_id;

    -- 4. Find latest active study subject
    -- Priority: most recent progress > most recent start date > deterministic ID ordering
    SELECT
        ss.id,
        MAX(sp.completed_at) as latest_progress
    INTO v_subject_id, v_latest_progress_date
    FROM public.study_subject ss
    LEFT JOIN public.subject_progress sp ON sp.subject_id = ss.id
    WHERE
        ss.user_id = p_user_id
        AND ss.is_deleted = false
        AND ss.started_at IS NOT NULL
    GROUP BY ss.id
    ORDER BY
        MAX(sp.completed_at) DESC NULLS LAST,  -- Most recent progress first
        ss.started_at DESC,                     -- Most recent start date as tiebreaker
        ss.id DESC                               -- Deterministic ordering for identical dates
    LIMIT 1;

    -- 5. Return success with credentials and optional subject_id
    RETURN jsonb_build_object(
        'success', true,
        'email', v_user_email,
        'password', v_new_password,
        'subject_id', v_subject_id  -- Will be null if no active studies found
    );

EXCEPTION
    WHEN OTHERS THEN
        -- Log error and return failure
        RAISE WARNING 'Error in recover_account for user %: %', p_user_id, SQLERRM;
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Recovery failed: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to anon and authenticated roles
-- (anon is required since users call this before authentication)
GRANT EXECUTE ON FUNCTION public.recover_account(uuid) TO anon, authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION public.recover_account(uuid) IS
'Recovers user account by generating new password and finding latest active study. Used for 13-word recovery phrase feature.';

COMMIT;
