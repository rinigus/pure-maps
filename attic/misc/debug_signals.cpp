// Insert snippet below before main() and small section into the main() function


// Signals debug
struct QSignalSpyCallbackSet
{
    typedef void (*BeginCallback)(QObject *caller, int signal_or_method_index, void **argv);
    typedef void (*EndCallback)(QObject *caller, int signal_or_method_index);
    BeginCallback signal_begin_callback,
                    slot_begin_callback;
    EndCallback signal_end_callback,
                slot_end_callback;
};
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
void Q_CORE_EXPORT qt_register_signal_spy_callbacks(const QSignalSpyCallbackSet &callback_set);
extern QSignalSpyCallbackSet Q_CORE_EXPORT qt_signal_spy_callback_set;
#else
void Q_CORE_EXPORT qt_register_signal_spy_callbacks(QSignalSpyCallbackSet *callback_set);
//extern Q_CORE_EXPORT QBasicAtomicPointer<QSignalSpyCallbackSet> qt_signal_spy_callback_set;
#endif

static void showObject(QObject *caller, int signal_index, const char *msg)
{
   const QMetaObject *metaObject = caller->metaObject();
   QMetaMethod member = metaObject->method(signal_index);
   std::cout << msg << " " << metaObject->className() << " " << qPrintable(member.name()) << std::endl;
}

static void onSignalBegin(QObject *caller, int signal_index, void **/*argv*/)
{
   showObject(caller, signal_index, "onSignalBegin");
}

static void onSignalEnd(QObject *caller, int signal_index)
{
   std::cout << "onSignalEnd" << std::endl;
}

static void onSlotBegin(QObject *caller, int signal_index, void **/*argv*/)
{
   showObject(caller, signal_index, "onSlotBegin");
}



int main(int argc, char *argv[])
{
  // Signals debug: begin
  static QSignalSpyCallbackSet spyset = { onSignalBegin, onSlotBegin, onSignalEnd, 0 };
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
  qt_register_signal_spy_callbacks(spyset);
#else
  qt_register_signal_spy_callbacks(&spyset);
#endif
}
