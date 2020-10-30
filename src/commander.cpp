/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#include "commander.h"

Commander *Commander::s_instance = nullptr;

Commander::Commander()
{

}

Commander* Commander::instance()
{
  if (!s_instance) s_instance = new Commander();
  return s_instance;
}
