// Database Setup Utility
// Helper functions to check and initialize database schema

import { createClient } from '@/lib/supabase/client'

export async function checkDatabaseConnection(): Promise<boolean> {
  try {
    const supabase = createClient()
    const { error } = await supabase.from('profiles').select('*', { head: true, count: 'exact' }).limit(1)
    
    return !error || error.code !== 'PGRST116'
  } catch (error) {
    console.error('Database connection check failed:', error)
    return false
  }
}

export async function checkTableExists(tableName: string): Promise<boolean> {
  try {
    const supabase = createClient()
    const { error } = await supabase.from(tableName).select('*', { head: true, count: 'exact' }).limit(1)
    
    // PGRST116 means the table/relation does not exist
    return !error || error.code !== 'PGRST116'
  } catch (error) {
    return false
  }
}

export interface DatabaseStatus {
  connected: boolean
  tablesExist: {
    profiles: boolean
    study_sessions: boolean
    achievements: boolean
    study_rooms: boolean
    tutor_profiles: boolean
  }
  isReady: boolean
}

export async function getDatabaseStatus(): Promise<DatabaseStatus> {
  const connected = await checkDatabaseConnection()
  
  if (!connected) {
    return {
      connected: false,
      tablesExist: {
        profiles: false,
        study_sessions: false,
        achievements: false,
        study_rooms: false,
        tutor_profiles: false,
      },
      isReady: false,
    }
  }

  const [profiles, study_sessions, achievements, study_rooms, tutor_profiles] = await Promise.all([
    checkTableExists('profiles'),
    checkTableExists('study_sessions'),
    checkTableExists('achievements'),
    checkTableExists('study_rooms'),
    checkTableExists('tutor_profiles'),
  ])

  const isReady = profiles && study_sessions && achievements && study_rooms && tutor_profiles

  return {
    connected: true,
    tablesExist: {
      profiles,
      study_sessions,
      achievements,
      study_rooms,
      tutor_profiles,
    },
    isReady,
  }
}

// Ensure user profile exists after authentication
export async function ensureProfileBootstrap(userId: string, email: string, displayName?: string, role?: 'student' | 'teacher'): Promise<{ success: boolean; error?: string }> {
  try {
    const supabase = createClient()
    
    // Check if profile already exists
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('user_id, role')
      .eq('user_id', userId)
      .single()
    
    if (existingProfile) {
      // Profile exists, check if tutor profile needs creation
      if (existingProfile.role === 'teacher') {
        const { data: tutorProfile } = await supabase
          .from('tutor_profiles')
          .select('user_id')
          .eq('user_id', userId)
          .single()
        
        if (!tutorProfile) {
          await supabase.from('tutor_profiles').insert({
            user_id: userId,
            bio: 'New tutor - profile setup pending',
            hourly_rate: 2500,
            subjects: [],
            availability: {},
          })
        }
      }
      return { success: true }
    }
    
    // Profile doesn't exist, create it
    const userRole = role || 'student'
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        user_id: userId,
        role: userRole,
        display_name: displayName || email.split('@')[0],
      })
    
    if (profileError) {
      console.error('Profile bootstrap error:', profileError)
      return { success: false, error: profileError.message }
    }
    
    // If teacher, create tutor profile
    if (userRole === 'teacher') {
      const { error: tutorError } = await supabase
        .from('tutor_profiles')
        .insert({
          user_id: userId,
          bio: 'New tutor - profile setup pending',
          hourly_rate: 2500,
          subjects: [],
          availability: {},
        })
      
      if (tutorError) {
        console.warn('Tutor profile creation failed:', tutorError)
      }
    }
    
    return { success: true }
  } catch (error: any) {
    console.error('ensureProfileBootstrap failed:', error)
    return { success: false, error: error.message }
  }
}
