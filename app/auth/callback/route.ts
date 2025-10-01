// OAuth Callback Route Handler for Supabase Auth
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const cookieStore = await cookies()
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          get(name: string) {
            return cookieStore.get(name)?.value
          },
          set(name: string, value: string, options: CookieOptions) {
            cookieStore.set({ name, value, ...options })
          },
          remove(name: string, options: CookieOptions) {
            cookieStore.set({ name, value: '', ...options })
          },
        },
      }
    )
    
    const { data: { session }, error } = await supabase.auth.exchangeCodeForSession(code)
    
    if (error) {
      console.error('Auth callback error:', error)
      return NextResponse.redirect(`${requestUrl.origin}/auth/login?error=callback_error`)
    }

    if (session) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('role, display_name')
        .eq('user_id', session.user.id)
        .single()

      if (!profile) {
        const displayName = session.user.user_metadata.full_name || 
                           session.user.user_metadata.name || 
                           session.user.user_metadata.display_name ||
                           session.user.email?.split('@')[0]

        const userRole = session.user.user_metadata.role || 'student'

        try {
          const { error: profileError } = await supabase
            .from('profiles')
            .insert({
              user_id: session.user.id,
              role: userRole,
              display_name: displayName,
            })

          if (profileError) {
            console.error('Profile creation error:', profileError)
          }

          if (userRole === 'teacher') {
            await supabase.from('tutor_profiles').insert({
              user_id: session.user.id,
              bio: 'New tutor - profile setup pending',
              hourly_rate: 2500,
              subjects: [],
              availability: {},
            })
          }
        } catch (e) {
          console.error('Profile bootstrap failed:', e)
        }

        const dashboardUrl = userRole === 'student' ? '/student' : '/teacher'
        return NextResponse.redirect(`${requestUrl.origin}${dashboardUrl}`)
      }

      const dashboardUrl = profile.role === 'student' ? '/student' : '/teacher'
      return NextResponse.redirect(`${requestUrl.origin}${dashboardUrl}`)
    }
  }

  return NextResponse.redirect(`${requestUrl.origin}/auth/login`)
}
