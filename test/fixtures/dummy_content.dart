
import 'package:commission_apparel_flutter/models/landing_collection.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:commission_apparel_flutter/models/site_setting.dart';

/// Dummy landing collections (hero tab cards on the public landing page).
final List<LandingCollection> rawdummyLandingCollections = [
  LandingCollection(
    id: 'landing-1',
    tabName: 'BASKETBALL',
    title: 'Elevate Your Game',
    description:
        'Custom sublimated basketball uniforms designed for performance '
        'and style. From jerseys to warm-ups, outfit your entire team.',
    sortOrder: 1,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  LandingCollection(
    id: 'landing-2',
    tabName: 'FOOTBALL',
    title: 'Built for the Gridiron',
    description:
        'Durable, high-performance football gear. Jerseys, pants, and '
        'sideline apparel built to withstand every down.',
    sortOrder: 2,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  LandingCollection(
    id: 'landing-3',
    tabName: 'TRACK & FIELD',
    title: 'Speed Meets Style',
    description:
        'Lightweight, aerodynamic uniforms for sprints, throws, and '
        'everything in between. Custom singlets and warm-ups.',
    sortOrder: 3,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  LandingCollection(
    id: 'landing-4',
    tabName: 'MERCH',
    title: 'Team Spirit Gear',
    description:
        'Hoodies, t-shirts, backpacks, and accessories. Perfect for fans, '
        'boosters, and team fundraising.',
    sortOrder: 4,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
];

/// Dummy testimonials for the public landing page.
final List<Testimonial> rawdummyTestimonials = [
  Testimonial(
    id: 'test-1',
    clientName: 'Justin Gatlin',
    organization: 'Olympic Track & Field',
    content:
        'Commission Apparel delivered exactly what we needed — high-quality '
        'custom gear with a fast turnaround. Our athletes love wearing it.',
    sortOrder: 1,
    createdAt: DateTime(2024, 2, 1),
    updatedAt: DateTime(2024, 2, 1),
  ),
  Testimonial(
    id: 'test-2',
    clientName: 'Jason Jacobs',
    organization: 'Metro Youth Basketball League',
    content:
        'The ordering process was seamless. Parents could pick sizes, '
        'coaches managed everything in one place, and the uniforms looked '
        'amazing. Highly recommend!',
    sortOrder: 2,
    createdAt: DateTime(2024, 3, 15),
    updatedAt: DateTime(2024, 3, 15),
  ),
  Testimonial(
    id: 'test-3',
    clientName: 'Sarah Williams',
    organization: 'Northview High School',
    content:
        'We switched to Commission Apparel for our football program and the '
        'difference is night and day. Professional designs, great pricing, '
        'and our fundraiser profits went up 40%.',
    sortOrder: 3,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
  ),
];

/// Dummy site settings matching the Laravel SiteSetting seeds.
final List<SiteSetting> rawdummySiteSettings = [
  SiteSetting(
    id: 'setting-1',
    key: 'hero_title',
    value: 'CUSTOM TEAM APPAREL MADE EASY',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-2',
    key: 'hero_subtitle',
    value:
        'Premium quality custom jerseys, uniforms, and team gear — '
        'designed by your coach, ordered by your parents.',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-3',
    key: 'hero_cta_text',
    value: 'Request A Quote',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-4',
    key: 'contact_email',
    value: 'info@commissionapparel.com',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-5',
    key: 'contact_phone',
    value: '(800) 555-0199',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-6',
    key: 'instagram_url',
    value: 'https://instagram.com/commissionapparel',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  SiteSetting(
    id: 'setting-7',
    key: 'twitter_url',
    value: 'https://twitter.com/commapparel',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
];



