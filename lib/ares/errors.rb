# frozen_string_literal: true

module Ares
  class AresError < RuntimeError
  end
  class RecordNotFound < AresError
  end
end
