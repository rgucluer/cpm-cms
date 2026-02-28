import { withPayload } from '@payloadcms/next/withPayload'

import redirects from './redirects.js'

// const NEXT_PUBLIC_SERVER_URL = process.env.NEXT_PUBLIC_SERVER_URL
//   ? `${process.env.NEXT_PUBLIC_SERVER_URL}`
//   : undefined || 'http://localhost:3000'

const NEXT_PUBLIC_SERVER_URL = process.env.NEXT_PUBLIC_SERVER_URL || 'http://localhost:3000'

const APP_ROOT_DN = process.env.APP_ROOT_DN

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      ...[NEXT_PUBLIC_SERVER_URL].map((item) => {
        const url = new URL(item)

        return {
          protocol: url.protocol.replace(':', ''),
          hostname: url.hostname,
          port: url.port || '',
          pathname: '/_next/static/chunks/**',
        }
      }),
      ...[NEXT_PUBLIC_SERVER_URL].map((item) => {
        const url = new URL(item)

        return {
          protocol: url.protocol.replace(':', ''),
          hostname: url.hostname,
          port: url.port || '',
          pathname: '/_next/image**',
        }
      }),
      ...[NEXT_PUBLIC_SERVER_URL].map((item) => {
        const url = new URL(item)

        return {
          protocol: url.protocol.replace(':', ''),
          hostname: url.hostname,
          port: url.port || '',
          pathname: '/api/media/file/**',
        }
      }),
      ...[NEXT_PUBLIC_SERVER_URL].map((item) => {
        const url = new URL(item)

        return {
          protocol: url.protocol.replace(':', ''),
          hostname: url.hostname,
          port: url.port || '',
          pathname: '/media/**',
        }
      }),
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '3000',
        pathname: '/api/media/file/**',
      },
    ],
  },
  webpack: (webpackConfig) => {
    webpackConfig.resolve.extensionAlias = {
      '.cjs': ['.cts', '.cjs'],
      '.js': ['.ts', '.tsx', '.js', '.jsx'],
      '.mjs': ['.mts', '.mjs'],
    }

    return webpackConfig
  },
  experimental: {
    webpackMemoryOptimizations: true,
  },
  output: 'standalone',
  reactStrictMode: true,
  redirects,
}

export default withPayload(nextConfig, { devBundleServerPackages: false })
