class Operation < ApplicationRecord
  belongs_to :user

  after_create {change_balance(self[:user_id], self[:credit], self[:value])}
  around_update :update_balance_when_edit_operation
  after_destroy {change_balance(self[:user_id], self[:credit], self[:value], rollback: true)}

  validates :value, presence: true
  validates_inclusion_of :credit, in: [true, false]
  validates :date, presence: true
  validates :user_id, presence: true

  self.per_page = 10

  filterrific(
    default_filter_params: { sorted_by: 'date_desc', with_credit: nil },
    available_filters: [
      :sorted_by,
      :search_comment,
      :with_value_gte,
      :with_value_lte,
      :with_date_gte,
      :with_date_lte,
      :with_tag,
      :with_credit
    ]
  )

  scope :with_credit, lambda { |cred|
    where(cred)
  }

  scope :with_tag, lambda { |tags| where(tag: [*tags]) }

  scope :search_comment, lambda { |comment|
    return nil  if comment.blank?
    terms = comment.to_s.downcase.split(/\s+/)
    terms = terms.map { |e| (e.gsub('*', '%') + '%').gsub(/%+/, '%') }
    where(
      terms.map { |term| "LOWER(operations.comment) LIKE ?" }.join(' AND '),
      *terms.map { |e| [e] }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^date_/
        order("operations.date #{ direction }")
      when /^value_/
        order("operations.value #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_date_gte, lambda { |date_min|
    where('operations.date >= ?', date_min)
  }

  scope :with_date_lte, lambda { |date_max|
    where('operations.date <= ?', date_max)
  }

  scope :with_value_gte, lambda { |value_min|
    where('operations.value >= ?', value_min)
  }

  scope :with_value_lte, lambda { |value_max|
    where('operations.value <= ?', value_max)
  }

  def self.options_for_sorted_by
    [
      ['Date (Descending)', 'date_desc'],
      ['Date (Ascending)', 'date_asc'],
      ['Value (Descending)', 'value_desc'],
      ['Value (Ascending)', 'value_asc']
    ]
  end

  def self.options_for_with_credit
    [
      ['ALL', ''],
      ['CREDIT', 'operations.credit = true'],
      ['DEBIT', 'operations.credit = false']
    ]
  end



    private

    def change_balance(user_id, credit, value, rollback: false)
      balance = User.find(user_id)[:balance]
      if rollback
        credit ? balance -= value : balance += value
      else
        credit ? balance += value : balance -= value
      end
      User.find(user_id).update_attribute(:balance, balance)
    end

    def update_balance_when_edit_operation
      old_credit = Operation.find(self[:id])[:credit]
      old_value = Operation.find(self[:id])[:value]
      yield
      change_balance(self[:user_id], old_credit, old_value, rollback: true)
      change_balance(self[:user_id], self[:credit], self[:value])
    end

end
