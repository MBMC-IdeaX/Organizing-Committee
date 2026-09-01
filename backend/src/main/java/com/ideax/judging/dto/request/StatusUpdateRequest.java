package com.ideax.judging.dto.request;

import jakarta.validation.constraints.NotNull;

public class StatusUpdateRequest {

    @NotNull(message = "Active status is required")
    private Boolean active;

    public StatusUpdateRequest() {
    }

    public StatusUpdateRequest(Boolean active) {
        this.active = active;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
