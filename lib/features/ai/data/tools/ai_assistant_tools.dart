class AiAssistantToolsRegistry {
  const AiAssistantToolsRegistry();

  Map<String, dynamic> buildRequestOptions({bool allowTools = true}) {
    if (!allowTools) {
      return <String, dynamic>{'tool_choice': 'none'};
    }
    return <String, dynamic>{'tools': _toolDefinitions, 'tool_choice': 'auto'};
  }

  static const List<Map<String, Object?>>
  _toolDefinitions = <Map<String, Object?>>[
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'get_spending_summary',
        'description':
            'Возвращает сумму расходов по валютам за период. '
            'Если нужно найти категорию или счет, сначала вызови '
            'find_categories или find_accounts.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'period': <String, Object?>{
              'type': 'string',
              'description':
                  'Период: current_month, month_to_date, last_month, '
                  'last_30_days, last_90_days, last_week, week_to_date, '
                  'year_to_date.',
            },
            'start_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата начала в ISO 8601 (если указан, period игнорируется).',
            },
            'end_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата конца в ISO 8601 (если указан, period игнорируется).',
            },
            'category_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по категориям (id).',
            },
            'account_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по счетам (id).',
            },
          },
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'get_income_summary',
        'description': 'Возвращает сумму доходов по валютам за период.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'period': <String, Object?>{
              'type': 'string',
              'description':
                  'Период: current_month, month_to_date, last_month, '
                  'last_30_days, last_90_days, last_week, week_to_date, '
                  'year_to_date.',
            },
            'start_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата начала в ISO 8601 (если указан, period игнорируется).',
            },
            'end_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата конца в ISO 8601 (если указан, period игнорируется).',
            },
            'category_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по категориям (id).',
            },
            'account_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по счетам (id).',
            },
          },
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'get_top_categories',
        'description': 'Возвращает топ категорий по сумме за период.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'type': <String, Object?>{
              'type': 'string',
              'enum': <String>['expense', 'income'],
              'description': 'Тип транзакций: expense или income.',
            },
            'period': <String, Object?>{
              'type': 'string',
              'description':
                  'Период: current_month, month_to_date, last_month, '
                  'last_30_days, last_90_days, last_week, week_to_date, '
                  'year_to_date.',
            },
            'start_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата начала в ISO 8601 (если указан, period игнорируется).',
            },
            'end_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата конца в ISO 8601 (если указан, period игнорируется).',
            },
            'limit': <String, Object?>{
              'type': 'integer',
              'description': 'Максимум категорий (до 10).',
            },
            'account_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по счетам (id).',
            },
          },
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'get_transactions',
        'description': 'Возвращает список транзакций с деталями.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'period': <String, Object?>{
              'type': 'string',
              'description':
                  'Период: current_month, month_to_date, last_month, '
                  'last_30_days, last_90_days, last_week, week_to_date, '
                  'year_to_date.',
            },
            'start_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата начала в ISO 8601 (если указан, period игнорируется).',
            },
            'end_date': <String, Object?>{
              'type': 'string',
              'description':
                  'Дата конца в ISO 8601 (если указан, period игнорируется).',
            },
            'category_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по категориям (id).',
            },
            'account_ids': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{'type': 'string'},
              'description': 'Фильтр по счетам (id).',
            },
            'transaction_type': <String, Object?>{
              'type': 'string',
              'description': 'Тип транзакций: expense или income.',
            },
            'limit': <String, Object?>{
              'type': 'integer',
              'description': 'Максимум транзакций (до 200).',
            },
          },
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'get_budgets',
        'description':
            'Возвращает бюджеты с прогрессом, категориями и остатками. '
            'Используй при вопросах о бюджетах, лимитах, превышениях и '
            'остатках по категориям бюджета.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'budget_id': <String, Object?>{
              'type': 'string',
              'description': 'ID конкретного бюджета (если нужен один).',
            },
            'category_limit': <String, Object?>{
              'type': 'integer',
              'description': 'Максимум категорий в деталях (до 50).',
            },
          },
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'find_categories',
        'description':
            'Ищет категории по названию. Используй для получения category_ids.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'query': <String, Object?>{
              'type': 'string',
              'description': 'Часть названия категории.',
            },
            'limit': <String, Object?>{
              'type': 'integer',
              'description': 'Максимум результатов (до 20).',
            },
          },
          'required': <String>['query'],
        },
      },
    },
    <String, Object?>{
      'type': 'function',
      'function': <String, Object?>{
        'name': 'find_accounts',
        'description':
            'Ищет счета по названию. Используй для получения account_ids.',
        'parameters': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'query': <String, Object?>{
              'type': 'string',
              'description': 'Часть названия счета.',
            },
            'limit': <String, Object?>{
              'type': 'integer',
              'description': 'Максимум результатов (до 20).',
            },
          },
          'required': <String>['query'],
        },
      },
    },
  ];
}
