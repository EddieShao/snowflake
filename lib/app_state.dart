import 'package:flutter/material.dart';

abstract class _AppState<T> extends ChangeNotifier {
    T _value;

    _AppState(this._value);

    T get value => _value;
    set value(T newValue) {
        _value = newValue;
        notifyListeners();
    }

    void force() {
        notifyListeners();
    }
}

class EditState<bool> extends _AppState { EditState(super.value); }
class DoneState<bool> extends _AppState { DoneState(super.value); }
