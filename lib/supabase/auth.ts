// Supabase Authentication Utilities (Client-side only)
import { createClient } from './client'

// Authentication types
export interface AuthUser {
  id: string
  email: string
  role: 'student' | 'teacher'
  profile: {
    display_name: string | null
    avatar_url: string | null
    total_xp: number
    study_level: number
  }
}

// Sign up new user with role
export async function signUpWithEmail(
  email: string, 
  password: string, 
  displayName: string,
  role: 'student' | 'teacher'
) {
  const supabase = createClient()
  
  try {
    // Step 1: Sign up with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          display_name: displayName,
          role: role,
        }
      }
    })

    if (authError) throw authError

    if (authData.user) {
      // Step 2: Create user profile
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          user_id: authData.user.id,
          role: role,
          display_name: displayName,
        })

      if (profileError) {
        console.warn('Profile creation failed:', profileError)
      }

      // Step 3: If teacher, initialize tutor profile
      if (role === 'teacher') {
        const { error: tutorError } = await supabase
          .from('tutor_profiles')
          .insert({
            user_id: authData.user.id,
            bio: 'New tutor - profile setup pending',
            hourly_rate: 2500,
            subjects: [],
            availability: {},
          })

        if (tutorError) console.warn('Tutor profile creation failed:', tutorError)
      }
    }

    return { data: authData, error: null }
  } catch (error: any) {
    console.error('Sign up error:', error)
    return { data: null, error: error.message || 'Failed to sign up' }
  }
}

// Sign in existing user
export async function signInWithEmail(email: string, password: string) {
  const supabase = createClient()
  
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) throw error
    return { data, error: null }
  } catch (error: any) {
    console.error('Sign in error:', error)
    return { data: null, error: error.message || 'Failed to sign in' }
  }
}

// OAuth sign in
export async function signInWithOAuth(provider: 'google' | 'github') {
  const supabase = createClient()
  
  try {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      }
    })

    if (error) throw error
    return { data, error: null }
  } catch (error: any) {
    console.error('OAuth sign in error:', error)
    return { data: null, error: error.message || 'OAuth failed' }
  }
}

// Sign out
export async function signOut() {
  const supabase = createClient()
  
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    window.location.href = '/'
    return { error: null }
  } catch (error: any) {
    console.error('Sign out error:', error)
    return { error: error.message || 'Failed to sign out' }
  }
}

// Get current user with profile (Client-side)
export async function getCurrentUser(): Promise<AuthUser | null> {
  const supabase = createClient()
  
  try {
    // Get current session
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) return null

    // Get user profile
    const { data: profile, error } = await supabase
      .from('profiles')
      .select(`
        role,
        display_name,
        avatar_url,
        total_xp,
        study_level
      `)
      .eq('user_id', session.user.id)
      .single()

    if (error) throw error
    if (!profile) return null

    return {
      id: session.user.id,
      email: session.user.email!,
      role: profile.role,
      profile: {
        display_name: profile.display_name,
        avatar_url: profile.avatar_url,
        total_xp: profile.total_xp,
        study_level: profile.study_level,
      }
    }
  } catch (error) {
    console.error('Get current user error:', error)
    return null
  }
}
