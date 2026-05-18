// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_impact_suppression.dart';

const _tracerName = 'dartastic_otel_libs_impact';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class ImpactResult {
  const ImpactResult({
    this.accountSid,
    this.programId,
    this.entityKind,
    this.entityId,
    this.actionId,
    this.actionType,
    this.actionStatus,
    this.partnerId,
    this.mediaPartnerType,
    this.campaignId,
    this.amountMinor,
    this.currency,
    this.commissionMinor,
    this.promoCode,
    this.payoutId,
    this.payoutStatus,
    this.creativeId,
    this.statusCode,
  });

  /// Impact account SID (the brand running the partnership program).
  final String? accountSid;

  /// Program id (a brand can run multiple programs — affiliate /
  /// influencer / referral / B2B partnerships).
  final String? programId;

  /// `action` / `partner` / `campaign` / `creative` / `payout` /
  /// `tracking_link` / `promo_code` / `contract` / `media_property` /
  /// `report` / `webhook`.
  final String? entityKind;

  final String? entityId;

  final String? actionId;

  /// `SALE` / `LEAD` / `INSTALL` / `IMPRESSION` / `CLICK` /
  /// `INTERACTION`.
  final String? actionType;

  /// `PENDING` / `APPROVED` / `REVERSED` / `LOCKED`.
  final String? actionStatus;

  final String? partnerId;

  /// `INFLUENCER` / `MASS_MEDIA` / `COUPON` / `CASHBACK` /
  /// `B2B` / `LOYALTY` / `CONTENT` / `MOBILE_APP` / `SUB_NETWORK`.
  final String? mediaPartnerType;

  final String? campaignId;

  /// Order/sale amount in minor units.
  final int? amountMinor;

  final String? currency;

  /// Commission paid out in minor units.
  final int? commissionMinor;

  /// Promo code the action was attributed to.
  final String? promoCode;

  final String? payoutId;

  /// `PENDING` / `READY` / `PAID` / `CANCELED`.
  final String? payoutStatus;

  final String? creativeId;

  final int? statusCode;
}

class ImpactCallResult<T> {
  const ImpactCallResult({required this.value, this.result});
  final T value;
  final ImpactResult? result;
}

/// Wraps an Impact API call in a CLIENT span. [operation] is one of
/// `actions.list`, `actions.get`, `actions.update`, `partners.list`,
/// `partners.invite`, `campaigns.list`, `campaigns.create`,
/// `creatives.list`, `tracking_links.create`, `promo_codes.list`,
/// `payouts.list`, `payouts.process`, `contracts.list`,
/// `media_properties.list`, `reports.run`, `events.send`.
Future<T> tracedImpact<T>({
  required String operation,
  required Future<ImpactCallResult<T>> Function() invoke,
}) async {
  if (impactInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'impact',
    'rpc.method': operation,
    'impact.operation': operation,
  };

  final span = _tracer().startSpan(
    'impact $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.accountSid != null) {
        extras.add(OTel.attributeString(
          'impact.account.sid',
          r.result!.accountSid!,
        ));
      }
      if (r.result!.programId != null) {
        extras.add(OTel.attributeString(
          'impact.program.id',
          r.result!.programId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'impact.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'impact.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.actionId != null) {
        extras.add(OTel.attributeString(
          'impact.action.id',
          r.result!.actionId!,
        ));
      }
      if (r.result!.actionType != null) {
        extras.add(OTel.attributeString(
          'impact.action.type',
          r.result!.actionType!,
        ));
      }
      if (r.result!.actionStatus != null) {
        extras.add(OTel.attributeString(
          'impact.action.status',
          r.result!.actionStatus!,
        ));
        if (r.result!.actionStatus == 'REVERSED') {
          span.setStatus(
            SpanStatusCode.Error,
            'Impact action REVERSED',
          );
        }
      }
      if (r.result!.partnerId != null) {
        extras.add(OTel.attributeString(
          'impact.partner.id',
          r.result!.partnerId!,
        ));
      }
      if (r.result!.mediaPartnerType != null) {
        extras.add(OTel.attributeString(
          'impact.media_partner.type',
          r.result!.mediaPartnerType!,
        ));
      }
      if (r.result!.campaignId != null) {
        extras.add(OTel.attributeString(
          'impact.campaign.id',
          r.result!.campaignId!,
        ));
      }
      if (r.result!.amountMinor != null) {
        extras.add(OTel.attributeInt(
          'impact.amount.minor',
          r.result!.amountMinor!,
        ));
      }
      if (r.result!.currency != null) {
        extras.add(OTel.attributeString(
          'impact.currency',
          r.result!.currency!,
        ));
      }
      if (r.result!.commissionMinor != null) {
        extras.add(OTel.attributeInt(
          'impact.commission.minor',
          r.result!.commissionMinor!,
        ));
      }
      if (r.result!.promoCode != null) {
        extras.add(OTel.attributeString(
          'impact.promo_code',
          r.result!.promoCode!,
        ));
      }
      if (r.result!.payoutId != null) {
        extras.add(OTel.attributeString(
          'impact.payout.id',
          r.result!.payoutId!,
        ));
      }
      if (r.result!.payoutStatus != null) {
        extras.add(OTel.attributeString(
          'impact.payout.status',
          r.result!.payoutStatus!,
        ));
      }
      if (r.result!.creativeId != null) {
        extras.add(OTel.attributeString(
          'impact.creative.id',
          r.result!.creativeId!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Impact HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
