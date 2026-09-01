package com.ideax.judging.dto.request;

public class SaveCommentRequest {

    private String comment;

    public SaveCommentRequest() {
    }

    public SaveCommentRequest(String comment) {
        this.comment = comment;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
