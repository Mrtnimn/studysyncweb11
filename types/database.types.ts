// StudySync Database Types - Generated from Supabase schema
// This matches the database.sql schema with proper TypeScript types

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          user_id: string
          role: 'student' | 'teacher'
          display_name: string | null
          bio: string | null
          avatar_url: string | null
          study_level: number
          total_xp: number
          study_streak: number
          longest_streak: number
          last_study_date: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          role: 'student' | 'teacher'
          display_name?: string | null
          bio?: string | null
          avatar_url?: string | null
          study_level?: number
          total_xp?: number
          study_streak?: number
          longest_streak?: number
          last_study_date?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          role?: 'student' | 'teacher'
          display_name?: string | null
          bio?: string | null
          avatar_url?: string | null
          study_level?: number
          total_xp?: number
          study_streak?: number
          longest_streak?: number
          last_study_date?: string | null
          updated_at?: string
        }
      }
      study_sessions: {
        Row: {
          id: string
          user_id: string
          subject: string
          duration_minutes: number
          xp_earned: number
          session_type: 'solo' | 'group' | 'tutoring'
          focus_score: number | null
          notes: string | null
          completed_at: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          subject: string
          duration_minutes: number
          xp_earned?: number
          session_type: 'solo' | 'group' | 'tutoring'
          focus_score?: number | null
          notes?: string | null
          completed_at?: string
          created_at?: string
        }
        Update: {
          subject?: string
          duration_minutes?: number
          xp_earned?: number
          session_type?: 'solo' | 'group' | 'tutoring'
          focus_score?: number | null
          notes?: string | null
          completed_at?: string
        }
      }
      achievements: {
        Row: {
          id: string
          name: string
          description: string
          icon: string
          xp_reward: number
          badge_color: string
          category: 'streak' | 'xp' | 'social' | 'focus' | 'milestone'
          unlock_criteria: Record<string, any>
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          description: string
          icon: string
          xp_reward?: number
          badge_color?: string
          category: 'streak' | 'xp' | 'social' | 'focus' | 'milestone'
          unlock_criteria: Record<string, any>
          created_at?: string
        }
        Update: {
          name?: string
          description?: string
          icon?: string
          xp_reward?: number
          badge_color?: string
          category?: 'streak' | 'xp' | 'social' | 'focus' | 'milestone'
          unlock_criteria?: Record<string, any>
        }
      }
      user_achievements: {
        Row: {
          id: string
          user_id: string
          achievement_id: string
          unlocked_at: string
          is_featured: boolean
        }
        Insert: {
          id?: string
          user_id: string
          achievement_id: string
          unlocked_at?: string
          is_featured?: boolean
        }
        Update: {
          is_featured?: boolean
        }
      }
      study_rooms: {
        Row: {
          id: string
          name: string
          subject: string
          description: string | null
          host_user_id: string
          max_participants: number
          current_participants: number
          is_active: boolean
          level_requirement: string
          daily_room_name: string | null
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          subject: string
          description?: string | null
          host_user_id: string
          max_participants?: number
          current_participants?: number
          is_active?: boolean
          level_requirement?: string
          daily_room_name?: string | null
          created_at?: string
        }
        Update: {
          name?: string
          subject?: string
          description?: string | null
          max_participants?: number
          current_participants?: number
          is_active?: boolean
          level_requirement?: string
          daily_room_name?: string | null
        }
      }
      room_participants: {
        Row: {
          id: string
          room_id: string
          user_id: string
          joined_at: string
          left_at: string | null
          is_active: boolean
        }
        Insert: {
          id?: string
          room_id: string
          user_id: string
          joined_at?: string
          left_at?: string | null
          is_active?: boolean
        }
        Update: {
          left_at?: string | null
          is_active?: boolean
        }
      }
      tutor_profiles: {
        Row: {
          id: string
          user_id: string
          bio: string
          hourly_rate: number
          subjects: string[]
          languages: string[]
          education: string | null
          experience_years: number
          availability: Record<string, any>
          timezone: string
          is_verified: boolean
          is_active: boolean
          total_sessions: number
          average_rating: number
          total_reviews: number
          response_time_hours: number
          stripe_account_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          bio: string
          hourly_rate: number
          subjects: string[]
          languages?: string[]
          education?: string | null
          experience_years?: number
          availability: Record<string, any>
          timezone?: string
          is_verified?: boolean
          is_active?: boolean
          total_sessions?: number
          average_rating?: number
          total_reviews?: number
          response_time_hours?: number
          stripe_account_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          bio?: string
          hourly_rate?: number
          subjects?: string[]
          languages?: string[]
          education?: string | null
          experience_years?: number
          availability?: Record<string, any>
          timezone?: string
          is_verified?: boolean
          is_active?: boolean
          total_sessions?: number
          average_rating?: number
          total_reviews?: number
          response_time_hours?: number
          stripe_account_id?: string | null
          updated_at?: string
        }
      }
      tutor_bookings: {
        Row: {
          id: string
          student_id: string
          tutor_id: string
          subject: string
          session_date: string
          duration_minutes: number
          hourly_rate: number
          total_cost: number
          status: 'pending' | 'confirmed' | 'completed' | 'cancelled'
          session_notes: string | null
          daily_room_name: string | null
          stripe_session_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          student_id: string
          tutor_id: string
          subject: string
          session_date: string
          duration_minutes: number
          hourly_rate: number
          total_cost: number
          status?: 'pending' | 'confirmed' | 'completed' | 'cancelled'
          session_notes?: string | null
          daily_room_name?: string | null
          stripe_session_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          subject?: string
          session_date?: string
          duration_minutes?: number
          status?: 'pending' | 'confirmed' | 'completed' | 'cancelled'
          session_notes?: string | null
          daily_room_name?: string | null
          stripe_session_id?: string | null
          updated_at?: string
        }
      }
      tutor_reviews: {
        Row: {
          id: string
          booking_id: string
          student_id: string
          tutor_id: string
          rating: number
          review_text: string | null
          created_at: string
        }
        Insert: {
          id?: string
          booking_id: string
          student_id: string
          tutor_id: string
          rating: number
          review_text?: string | null
          created_at?: string
        }
        Update: {
          rating?: number
          review_text?: string | null
        }
      }
      messages: {
        Row: {
          id: string
          room_id: string | null
          booking_id: string | null
          sender_id: string
          content: string
          message_type: 'text' | 'file' | 'system'
          file_url: string | null
          created_at: string
        }
        Insert: {
          id?: string
          room_id?: string | null
          booking_id?: string | null
          sender_id: string
          content: string
          message_type?: 'text' | 'file' | 'system'
          file_url?: string | null
          created_at?: string
        }
        Update: {
          content?: string
          message_type?: 'text' | 'file' | 'system'
          file_url?: string | null
        }
      }
    }
  }
}

// Additional Types for Application Use
export type Profile = Database['public']['Tables']['profiles']['Row']
export type ProfileInsert = Database['public']['Tables']['profiles']['Insert']
export type ProfileUpdate = Database['public']['Tables']['profiles']['Update']

export type StudySession = Database['public']['Tables']['study_sessions']['Row']
export type StudySessionInsert = Database['public']['Tables']['study_sessions']['Insert']

export type Achievement = Database['public']['Tables']['achievements']['Row']
export type UserAchievement = Database['public']['Tables']['user_achievements']['Row']

export type StudyRoom = Database['public']['Tables']['study_rooms']['Row']
export type StudyRoomInsert = Database['public']['Tables']['study_rooms']['Insert']

export type TutorProfile = Database['public']['Tables']['tutor_profiles']['Row']
export type TutorProfileInsert = Database['public']['Tables']['tutor_profiles']['Insert']
export type TutorProfileUpdate = Database['public']['Tables']['tutor_profiles']['Update']

export type TutorBooking = Database['public']['Tables']['tutor_bookings']['Row']
export type TutorBookingInsert = Database['public']['Tables']['tutor_bookings']['Insert']

export type TutorReview = Database['public']['Tables']['tutor_reviews']['Row']
export type Message = Database['public']['Tables']['messages']['Row']

// User Role Types
export type UserRole = 'student' | 'teacher'
export type SessionType = 'solo' | 'group' | 'tutoring'
export type BookingStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled'
export type MessageType = 'text' | 'file' | 'system'
export type AchievementCategory = 'streak' | 'xp' | 'social' | 'focus' | 'milestone'