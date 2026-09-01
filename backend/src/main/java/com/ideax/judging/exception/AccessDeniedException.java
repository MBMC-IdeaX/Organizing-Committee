package com.ideax.judging.exception;

import org.springframework.http.HttpStatus;

public class AccessDeniedException extends AppException {
    public AccessDeniedException(String message) {
        super(message, HttpStatus.FORBIDDEN, ErrorCode.ACCESS_DENIED);
    }
}
