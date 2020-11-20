#ifndef PROMPT_H
#define PROMPT_H

#include <QString>

struct Prompt
{
public:
  Prompt();

  double duration() const;
  double length() const;

public:
  double dist_m;
  double time;
  double speed_m;
  QString text;
  int importance;
  bool flagged{false};
  bool requested{false};
};

#endif // PROMPT_H
