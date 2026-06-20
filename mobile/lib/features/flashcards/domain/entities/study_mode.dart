enum StudyMode {
  smart,     // 50% new, 30% difficult, 20% review
  newCards,
  review,
  difficult,
  favorite,
  fading;    // studied cards slipping below target retention, most-forgotten first
}
