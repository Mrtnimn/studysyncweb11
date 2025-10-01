// Next.js Middleware for Authentication and Role-based Routing
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return req.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          req.cookies.set({ name, value, ...options })
          res.cookies.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          req.cookies.set({ name, value: '', ...options })
          res.cookies.set({ name, value: '', ...options })
        },
      },
    }
  )

  const {
    data: { session },
  } = await supabase.auth.getSession()

  const { pathname } = req.nextUrl

  // Auth callback handling
  if (pathname.startsWith('/auth/callback')) {
    return res
  }

  // Public routes that don't require authentication
  const publicRoutes = ['/', '/auth/login', '/auth/register']
  if (publicRoutes.includes(pathname)) {
    // If user is logged in and trying to access auth pages, redirect to dashboard
    if (session && (pathname === '/auth/login' || pathname === '/auth/register')) {
      const redirectUrl = await getUserDashboard(supabase, session.user.id)
      return NextResponse.redirect(new URL(redirectUrl, req.url))
    }
    return res
  }

  // Protected routes - require authentication
  if (!session) {
    const redirectUrl = new URL('/auth/login', req.url)
    redirectUrl.searchParams.set('returnUrl', pathname)
    return NextResponse.redirect(redirectUrl)
  }

  // Role-based route protection
  const userProfile = await getUserProfile(supabase, session.user.id)
  
  if (!userProfile) {
    // User has no profile, redirect to setup
    return NextResponse.redirect(new URL('/auth/setup', req.url))
  }

  // Student routes
  if (pathname.startsWith('/student')) {
    if (userProfile.role !== 'student') {
      return NextResponse.redirect(new URL('/teacher', req.url))
    }
    return res
  }

  // Teacher routes  
  if (pathname.startsWith('/teacher')) {
    if (userProfile.role !== 'teacher') {
      return NextResponse.redirect(new URL('/student', req.url))
    }
    return res
  }

  // Dashboard redirect - redirect to appropriate role dashboard
  if (pathname === '/dashboard') {
    const redirectUrl = userProfile.role === 'student' ? '/student' : '/teacher'
    return NextResponse.redirect(new URL(redirectUrl, req.url))
  }

  return res
}

// Helper function to get user profile
async function getUserProfile(supabase: any, userId: string) {
  try {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role, display_name')
      .eq('user_id', userId)
      .single()

    return profile
  } catch (error) {
    console.error('Error fetching user profile:', error)
    return null
  }
}

// Helper function to determine user dashboard URL
async function getUserDashboard(supabase: any, userId: string) {
  const profile = await getUserProfile(supabase, userId)
  return profile?.role === 'student' ? '/student' : '/teacher'
}

// Configure which routes the middleware runs on
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}