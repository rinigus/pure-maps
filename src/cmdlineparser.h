#ifndef CMDLINEPARSER_H
#define CMDLINEPARSER_H

#include <QCommandLineParser>
#include <QObject>
#include <QStringList>

class CmdLineParser : public QObject
{
  Q_OBJECT

public:
  explicit CmdLineParser(QObject *parent = nullptr);

  bool parse(const QStringList &arguments);

  // process stored cmd line arguments
  Q_INVOKABLE void process();

public:
  static CmdLineParser* instance();

private:
  QCommandLineParser m_parser;
  static CmdLineParser* s_instance;
};

#endif // CMDLINEPARSER_H
