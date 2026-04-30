import { buildConfig } from 'payload'
import { mongooseAdapter } from '@payloadcms/db-mongodb'

const databaseURI = process.env.DATABASE_URI
const payloadSecret = process.env.PAYLOAD_SECRET

if (!databaseURI) {
  throw new Error('DATABASE_URI is required for Payload')
}

if (!payloadSecret) {
  throw new Error('PAYLOAD_SECRET is required for Payload')
}

export default buildConfig({
  secret: payloadSecret,
  db: mongooseAdapter({
    url: databaseURI,
  }),
  routes: {
    api: '/api/payload',
  },
  collections: [
    {
      slug: 'waitlist',
      admin: {
        useAsTitle: 'email',
      },
      access: {
        create: () => true,
      },
      fields: [
        {
          name: 'email',
          type: 'email',
          required: true,
          unique: true,
        },
        {
          name: 'source',
          type: 'text',
          required: false,
        },
      ],
    },
  ],
})
