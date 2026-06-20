enum CardGrade {
  again,
  hard,
  good,
  easy;

  int get sm2Value => switch (this) {
        CardGrade.again => 1,
        CardGrade.hard => 3,
        CardGrade.good => 4,
        CardGrade.easy => 5,
      };
}
