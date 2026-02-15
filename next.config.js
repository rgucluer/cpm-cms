import { withPayload } from '@payloadcms/next/withPayload'

import redirects from './redirects.js'

const NEXT_PUBLIC_SERVER_URL = process.env.NEXT_PUBLIC_SERVER_URL
  ? `${process.env.NEXT_PUBLIC_SERVER_URL}`
  : undefined || process.env.__NEXT_PRIVATE_ORIGIN || 'http://localhost:3000'

const APP_ROOT_DN = process.env.APP_ROOT_DN
const SERV_L_IP = process.env.SERV_L_IP

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      ...[NEXT_PUBLIC_SERVER_URL].map((item) => {
        const url = new URL(item)

        return {
          hostname: url.hostname,
          protocol: url.protocol.replace(':', ''),
          pathname: '/media/**',
        }
      }),
      {
        hostname: 'www.' + APP_ROOT_DN,
        protocol: 'https',
        pathname: '/media/**',
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
  allowedDevOrigins: [APP_ROOT_DN, '*.' + APP_ROOT_DN],
  redirects,
}

export default withPayload(nextConfig, { devBundleServerPackages: false })
