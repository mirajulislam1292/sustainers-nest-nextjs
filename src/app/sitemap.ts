import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const routes = ["", "/about", "/programs", "/journal", "/contact", "/request-workshop"];
  return routes.map((route) => ({ url: `https://sustainersnest.org${route}`, lastModified: new Date() }));
}
