"""Безопасная обработка транзакции для демонстрации DFA-исправлений."""


def process_transaction(user_id, amount, db_connection):
    """Обновляет баланс только для положительной суммы и возвращает статус."""
    status = "pending"
    if amount > 0:
        balance = get_balance(user_id, db_connection)
        new_balance = balance - amount
        update_balance(user_id, new_balance, db_connection)
        status = "approved"

    log_entry = f"Transaction finished with status: {status}"
    with open("audit_log.txt", "w", encoding="utf-8") as audit_file:
        audit_file.write(log_entry)
    return status


def get_balance(user_id, db_connection):
    """Возвращает баланс через подключение; выделено для тестируемости примера."""
    return db_connection.get_balance(user_id)


def update_balance(user_id, new_balance, db_connection):
    """Сохраняет баланс через подключение."""
    db_connection.update_balance(user_id, new_balance)
