/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "http",
        hostname: "localhost",
        port: "5000",
        pathname: "/api/v1/photos/**",
      },
      {
        protocol: "https",
        hostname: "**",
        pathname: "/api/v1/photos/**",
      },
    ],
  },
};

export default nextConfig;
