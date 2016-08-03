# Backport the Rails 5 controller test methods to Rails 4
module BackportTestHelpers
  def delete(*args)
    (action, rest) = *args
    rest ||= {}

    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if rest[:xhr]

    super(action, rest[:params])
  end

  def get(*args)
    (action, rest) = *args
    rest ||= {}
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if rest[:xhr]
    super(action, rest[:params])
  end

  def post(*args)
    (action, rest) = *args
    rest ||= {}
    body = rest[:body]
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if rest[:xhr]

    if body
      super(action, body, rest.except(:params).merge(rest[:params]))
    else
      super(action, rest[:params])
    end
  end

  def put(*args)
    (action, rest) = *args
    rest ||= {}
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if rest[:xhr]
    super(action, rest[:params])
  end

  def patch(*args)
    (action, rest) = *args
    rest ||= {}
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if rest[:xhr]
    super(action, rest[:params])
  end
end
