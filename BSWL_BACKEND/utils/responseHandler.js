export const successResponse = (res, data, statusCode = 200) => {
  res.status(statusCode).json({
    success: true,
    data
  });
};

export const errorResponse = (res, message, statusCode = 500, errors = null) => {
  const response = {
    success: false,
    message
  };
  
  if (errors) {
    response.errors = errors;
  }
  
  if (process.env.NODE_ENV === 'development' && statusCode === 500) {
    response.stack = message.stack;
  }
  
  res.status(statusCode).json(response);
};

export const paginatedResponse = (res, data, pagination) => {
  res.status(200).json({
    success: true,
    data,
    pagination
  });
};