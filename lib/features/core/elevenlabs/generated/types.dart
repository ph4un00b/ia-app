// To parse this JSON data, do
//
//     final voices = voicesFromJson(jsonString);

import 'dart:convert';

Voices voicesFromJson(String str) => Voices.fromJson(json.decode(str));

String voicesToJson(Voices data) => json.encode(data.toJson());

class Voices {
  final List<Voice>? voices;

  Voices({
    this.voices,
  });

  factory Voices.fromJson(Map<String, dynamic> json) => Voices(
        voices: json["voices"] == null ? [] : List<Voice>.from(json["voices"]!.map((x) => Voice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "voices": voices == null ? [] : List<dynamic>.from(voices!.map((x) => x.toJson())),
      };
}

class Voice {
  final String? voiceId;
  final String? name;
  final dynamic samples;
  final String? category;
  final FineTuning? fineTuning;
  final Labels? labels;
  final dynamic description;
  final String? previewUrl;
  final List<dynamic>? availableForTiers;
  final dynamic settings;
  final dynamic sharing;
  final List<String>? highQualityBaseModelIds;
  final dynamic safetyControl;
  final VoiceVerification? voiceVerification;
  final dynamic ownerId;
  final dynamic permissionOnResource;

  Voice({
    this.voiceId,
    this.name,
    this.samples,
    this.category,
    this.fineTuning,
    this.labels,
    this.description,
    this.previewUrl,
    this.availableForTiers,
    this.settings,
    this.sharing,
    this.highQualityBaseModelIds,
    this.safetyControl,
    this.voiceVerification,
    this.ownerId,
    this.permissionOnResource,
  });

  factory Voice.fromJson(Map<String, dynamic> json) => Voice(
        voiceId: json["voice_id"],
        name: json["name"],
        samples: json["samples"],
        category: json["category"],
        fineTuning: json["fine_tuning"] == null ? null : FineTuning.fromJson(json["fine_tuning"]),
        labels: json["labels"] == null ? null : Labels.fromJson(json["labels"]),
        description: json["description"],
        previewUrl: json["preview_url"],
        availableForTiers: json["available_for_tiers"] == null ? [] : List<dynamic>.from(json["available_for_tiers"]!.map((x) => x)),
        settings: json["settings"],
        sharing: json["sharing"],
        highQualityBaseModelIds: json["high_quality_base_model_ids"] == null ? [] : List<String>.from(json["high_quality_base_model_ids"]!.map((x) => x)),
        safetyControl: json["safety_control"],
        voiceVerification: json["voice_verification"] == null ? null : VoiceVerification.fromJson(json["voice_verification"]),
        ownerId: json["owner_id"],
        permissionOnResource: json["permission_on_resource"],
      );

  Map<String, dynamic> toJson() => {
        "voice_id": voiceId,
        "name": name,
        "samples": samples,
        "category": category,
        "fine_tuning": fineTuning?.toJson(),
        "labels": labels?.toJson(),
        "description": description,
        "preview_url": previewUrl,
        "available_for_tiers": availableForTiers == null ? [] : List<dynamic>.from(availableForTiers!.map((x) => x)),
        "settings": settings,
        "sharing": sharing,
        "high_quality_base_model_ids": highQualityBaseModelIds == null ? [] : List<dynamic>.from(highQualityBaseModelIds!.map((x) => x)),
        "safety_control": safetyControl,
        "voice_verification": voiceVerification?.toJson(),
        "owner_id": ownerId,
        "permission_on_resource": permissionOnResource,
      };
}

class FineTuning {
  final bool? isAllowedToFineTune;
  final String? finetuningState;
  final List<dynamic>? verificationFailures;
  final int? verificationAttemptsCount;
  final bool? manualVerificationRequested;
  final String? language;
  final FinetuningProgress? finetuningProgress;
  final dynamic message;
  final dynamic datasetDurationSeconds;
  final dynamic verificationAttempts;
  final dynamic sliceIds;
  final dynamic manualVerification;

  FineTuning({
    this.isAllowedToFineTune,
    this.finetuningState,
    this.verificationFailures,
    this.verificationAttemptsCount,
    this.manualVerificationRequested,
    this.language,
    this.finetuningProgress,
    this.message,
    this.datasetDurationSeconds,
    this.verificationAttempts,
    this.sliceIds,
    this.manualVerification,
  });

  factory FineTuning.fromJson(Map<String, dynamic> json) => FineTuning(
        isAllowedToFineTune: json["is_allowed_to_fine_tune"],
        finetuningState: json["finetuning_state"],
        verificationFailures: json["verification_failures"] == null ? [] : List<dynamic>.from(json["verification_failures"]!.map((x) => x)),
        verificationAttemptsCount: json["verification_attempts_count"],
        manualVerificationRequested: json["manual_verification_requested"],
        language: json["language"],
        finetuningProgress: json["finetuning_progress"] == null ? null : FinetuningProgress.fromJson(json["finetuning_progress"]),
        message: json["message"],
        datasetDurationSeconds: json["dataset_duration_seconds"],
        verificationAttempts: json["verification_attempts"],
        sliceIds: json["slice_ids"],
        manualVerification: json["manual_verification"],
      );

  Map<String, dynamic> toJson() => {
        "is_allowed_to_fine_tune": isAllowedToFineTune,
        "finetuning_state": finetuningState,
        "verification_failures": verificationFailures == null ? [] : List<dynamic>.from(verificationFailures!.map((x) => x)),
        "verification_attempts_count": verificationAttemptsCount,
        "manual_verification_requested": manualVerificationRequested,
        "language": language,
        "finetuning_progress": finetuningProgress?.toJson(),
        "message": message,
        "dataset_duration_seconds": datasetDurationSeconds,
        "verification_attempts": verificationAttempts,
        "slice_ids": sliceIds,
        "manual_verification": manualVerification,
      };
}

class FinetuningProgress {
  FinetuningProgress();

  factory FinetuningProgress.fromJson(Map<String, dynamic> json) => FinetuningProgress();

  Map<String, dynamic> toJson() => {};
}

class Labels {
  final String? accent;
  final String? description;
  final String? age;
  final String? gender;
  final String? useCase;
  final String? labelsDescription;
  final String? usecase;

  Labels({
    this.accent,
    this.description,
    this.age,
    this.gender,
    this.useCase,
    this.labelsDescription,
    this.usecase,
  });

  factory Labels.fromJson(Map<String, dynamic> json) => Labels(
        accent: json["accent"],
        description: json["description"],
        age: json["age"],
        gender: json["gender"],
        useCase: json["use case"],
        labelsDescription: json["description "],
        usecase: json["usecase"],
      );

  Map<String, dynamic> toJson() => {
        "accent": accent,
        "description": description,
        "age": age,
        "gender": gender,
        "use case": useCase,
        "description ": labelsDescription,
        "usecase": usecase,
      };
}

class VoiceVerification {
  final bool? requiresVerification;
  final bool? isVerified;
  final List<dynamic>? verificationFailures;
  final int? verificationAttemptsCount;
  final dynamic language;
  final dynamic verificationAttempts;

  VoiceVerification({
    this.requiresVerification,
    this.isVerified,
    this.verificationFailures,
    this.verificationAttemptsCount,
    this.language,
    this.verificationAttempts,
  });

  factory VoiceVerification.fromJson(Map<String, dynamic> json) => VoiceVerification(
        requiresVerification: json["requires_verification"],
        isVerified: json["is_verified"],
        verificationFailures: json["verification_failures"] == null ? [] : List<dynamic>.from(json["verification_failures"]!.map((x) => x)),
        verificationAttemptsCount: json["verification_attempts_count"],
        language: json["language"],
        verificationAttempts: json["verification_attempts"],
      );

  Map<String, dynamic> toJson() => {
        "requires_verification": requiresVerification,
        "is_verified": isVerified,
        "verification_failures": verificationFailures == null ? [] : List<dynamic>.from(verificationFailures!.map((x) => x)),
        "verification_attempts_count": verificationAttemptsCount,
        "language": language,
        "verification_attempts": verificationAttempts,
      };
}
