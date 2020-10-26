#include "cmdlineparser.h"

#include "commander.h"

#include <QCoreApplication>
#include <QRegularExpression>

#include <iostream>

#include <QDebug>

CmdLineParser *CmdLineParser::s_instance = nullptr;

CmdLineParser::CmdLineParser(QObject *parent) : QObject(parent)
{
  m_parser.setApplicationDescription("Pure Maps");
  const QCommandLineOption help(QStringList() << "h" << "help",
                                QCoreApplication::translate("", "Displays help on commandline options."));
  const QCommandLineOption version(QStringList() << "v" << "version",
                                QCoreApplication::translate("", "Displays version information."));
  m_parser.addOption(help);
  m_parser.addOption(version);
  m_parser.addPositionalArgument("location", QCoreApplication::translate("", "Show location given by geo:latitude,longitude URI or perform search."));
}

CmdLineParser* CmdLineParser::instance()
{
  if (!s_instance) s_instance = new CmdLineParser();
  return s_instance;
}

bool CmdLineParser::parse(const QStringList &arguments)
{
  bool r = m_parser.parse(arguments);

  if (m_parser.isSet("help"))
    {
      std::cout << m_parser.helpText().toStdString().c_str() << std::endl;
      return false;
    }

  if (m_parser.isSet("version"))
    {
      std::cout << "Pure Maps " APP_VERSION << std::endl;
      return false;
    }

  if (!r)
    {
      std::cout << m_parser.errorText().toStdString().c_str() << std::endl;
      return false;
    }

  return r;
}

void CmdLineParser::process()
{
  const QStringList args = m_parser.positionalArguments();
  if (args.length() > 0)
    {
      // either geo: URI or search string
      QString location = args[0];
      QRegularExpression re("^ *geo:(-?[\\d.]+),(-?[\\d.]+) *$");
      QRegularExpressionMatch match = re.match(location);
      bool isGeo = false;
      if (match.hasMatch())
        {
          isGeo = true;
          bool ok = true;
          double lat = match.captured(1).toDouble(&ok); isGeo = isGeo && ok;
          double lon = match.captured(2).toDouble(&ok); isGeo = isGeo && ok;
          if (isGeo) Commander::instance()->showPoi(QStringLiteral(), lat, lon);
        }

      if (!match.hasMatch() || !isGeo)
        Commander::instance()->search(location);
    }
}
