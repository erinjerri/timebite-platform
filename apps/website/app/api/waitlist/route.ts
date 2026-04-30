import config from '@/payload.config'
import { getPayload } from 'payload'

export async function POST(req: Request) {
  console.info('[waitlist] POST /api/waitlist')

  let body: unknown

  try {
    body = await req.json()
  } catch {
    return Response.json({ error: 'Invalid JSON body' }, { status: 400 })
  }

  if (!body || typeof body !== 'object') {
    return Response.json({ error: 'Invalid JSON body' }, { status: 400 })
  }

  const data = body as Record<string, unknown>
  const email = typeof data.email === 'string' ? data.email.trim().toLowerCase() : ''

  if (!email) {
    return Response.json({ error: 'Email is required' }, { status: 400 })
  }

  const payload = await getPayload({ config })

  try {
    const doc = await payload.create({
      collection: 'waitlist',
      data: {
        email,
        source: typeof data.source === 'string' ? data.source : undefined,
      },
    })

    return Response.json({ success: true, id: doc.id })
  } catch (error) {
    console.error('[waitlist] failed to create entry', error)
    return Response.json({ error: 'Unable to join waitlist' }, { status: 500 })
  }
}
