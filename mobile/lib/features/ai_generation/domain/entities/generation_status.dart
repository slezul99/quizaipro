enum GenerationStatus { pending, processing, completed, failed, cancelled }

extension GenerationStatusX on GenerationStatus {
  bool get isTerminal =>
      this == GenerationStatus.completed ||
      this == GenerationStatus.failed ||
      this == GenerationStatus.cancelled;

  bool get isActive =>
      this == GenerationStatus.pending ||
      this == GenerationStatus.processing;
}
