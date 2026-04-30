import config from '@/payload.config'
import { getPayload } from 'payload'

const jsonHeaders = {
  'content-type': 'application/json',
}

async function handler(req: Request) {
  console.info(`[payload] ${req.method} /api/payload`)

  const payload = await getPayload({ config })

  return Response.json(
    {
      ok: true,
      route: '/api/payload',
      collections: Object.keys(payload.collections),
    },
    { headers: jsonHeaders },
  )
}

export const GET = handler
export const POST = handler
