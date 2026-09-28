
import 'package:commission_apparel_flutter/models/quote_request.dart';

/// Dummy quote requests for testing admin quote management.
final List<QuoteRequest> rawdummyQuoteRequests = [
  QuoteRequest(
    id: 'quote-1',
    firstName: 'Michael',
    lastName: 'Thompson',
    positionTitle: 'Athletic Director',
    email: 'mthompson@centralhs.edu',
    phone: '(555) 444-5555',
    organizationName: 'Central High School',
    apparelCategory: 'Basketball',
    estimatedQuantity: '51-100',
    packageType: 'full_program_bundle',
    targetDeliveryDate: DateTime.now().add(const Duration(days: 60)),
    designVision:
        'We want a modern look with our school colors (navy and gold). '
        'Need jerseys, shorts, shooting shirts, and hoodies for varsity '
        'and JV teams.',
    status: 'new',
    createdAt: DateTime(2024, 7, 15),
    updatedAt: DateTime(2024, 7, 15),
  ),
  QuoteRequest(
    id: 'quote-2',
    firstName: 'Lisa',
    lastName: 'Fernandez',
    email: 'lisa.f@youthsports.org',
    phone: '(555) 666-7777',
    organizationName: 'Youth Sports Alliance',
    apparelCategory: 'Soccer',
    estimatedQuantity: '101-250',
    packageType: 'base_uniforms',
    targetDeliveryDate: DateTime.now().add(const Duration(days: 90)),
    designVision:
        'Looking for affordable but quality soccer jerseys for our '
        'community youth league. 12 teams, each needs unique colors.',
    status: 'addressed',
    createdAt: DateTime(2024, 6, 20),
    updatedAt: DateTime(2024, 7, 1),
  ),
  QuoteRequest(
    id: 'quote-3',
    firstName: 'Robert',
    lastName: 'Kim',
    positionTitle: 'Head Coach',
    email: 'rkim@eagles.com',
    organizationName: 'Eagles Track Club',
    apparelCategory: 'Track & Field',
    estimatedQuantity: '26-50',
    packageType: 'merch_only',
    designVision:
        'Need team hoodies and t-shirts for our club fundraiser. '
        'Want something sleek and modern that athletes will actually wear.',
    status: 'new',
    createdAt: DateTime(2024, 8, 1),
    updatedAt: DateTime(2024, 8, 1),
  ),
];

