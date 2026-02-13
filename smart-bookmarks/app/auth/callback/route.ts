import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (!code) {
    return new Response('No code received')
  }

  const supabase = await createClient()

  const { data, error } = await supabase.auth.exchangeCodeForSession(code)

  console.log('SESSION DATA:', data)
  console.log('SESSION ERROR:', error)

  if (error) {
    return new Response(`Auth Error: ${error.message}`)
  }

  return NextResponse.redirect(`${origin}/dashboard`)
}
