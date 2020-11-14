#include "prompt.h"

Prompt::Prompt()
{
}

double Prompt::duration() const
{
  return text.length() / 10.0;
}

double Prompt::length() const
{
  return duration() * speed_m;
}
