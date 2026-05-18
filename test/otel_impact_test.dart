// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_impact/otel_impact.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_impact-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('actions.list records partner type + commission + currency', () async {
    await tracedImpact<String>(
      operation: 'actions.list',
      invoke: () async => const ImpactCallResult(
        value: 'ok',
        result: ImpactResult(
          accountSid: 'sid_1',
          programId: 'prog_1',
          actionId: 'act_1',
          actionType: 'SALE',
          actionStatus: 'APPROVED',
          partnerId: 'partner_1',
          mediaPartnerType: 'INFLUENCER',
          campaignId: 'camp_1',
          amountMinor: 12500,
          currency: 'USD',
          commissionMinor: 1250,
          promoCode: 'INFLUENCER10',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('impact actions.list')!);
    expect(a['impact.action.type'], 'SALE');
    expect(a['impact.media_partner.type'], 'INFLUENCER');
    expect(a['impact.commission.minor'], 1250);
    expect(a['impact.promo_code'], 'INFLUENCER10');
  });

  test('REVERSED action sets span error', () async {
    await tracedImpact<String>(
      operation: 'actions.update',
      invoke: () async => const ImpactCallResult(
        value: 'ok',
        result: ImpactResult(
          actionId: 'act_2',
          actionStatus: 'REVERSED',
        ),
      ),
    );
    expect(
      spans.findSpanByName('impact actions.update')!.status,
      SpanStatusCode.Error,
    );
  });

  test('payouts.process records status', () async {
    await tracedImpact<String>(
      operation: 'payouts.process',
      invoke: () async => const ImpactCallResult(
        value: 'ok',
        result: ImpactResult(
          payoutId: 'p_1',
          payoutStatus: 'PAID',
          amountMinor: 250000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('impact payouts.process')!);
    expect(a['impact.payout.status'], 'PAID');
    expect(a['impact.amount.minor'], 250000);
  });

  test('suppression skips spans', () async {
    await runWithoutImpactInstrumentationAsync(() async {
      await tracedImpact<String>(
        operation: 'campaigns.list',
        invoke: () async => const ImpactCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('impact '), isEmpty);
  });
}
