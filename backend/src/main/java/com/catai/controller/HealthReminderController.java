package com.catai.controller;

import com.catai.dto.request.HealthReminderRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.HealthReminderResponse;
import com.catai.service.HealthReminderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class HealthReminderController {

    private final HealthReminderService healthReminderService;

    @GetMapping("/api/pets/{petId}/reminders")
    public ResponseEntity<ApiResponse<List<HealthReminderResponse>>> getReminders(
            @PathVariable String petId, Authentication auth) {
        String userId = auth.getName();
        List<HealthReminderResponse> reminders = healthReminderService.getReminders(petId, userId);
        return ResponseEntity.ok(ApiResponse.success(reminders));
    }

    @GetMapping("/api/pets/{petId}/reminders/today")
    public ResponseEntity<ApiResponse<List<HealthReminderResponse>>> getTodayReminders(
            @PathVariable String petId, Authentication auth) {
        String userId = auth.getName();
        List<HealthReminderResponse> reminders = healthReminderService.getTodayReminders(petId, userId);
        return ResponseEntity.ok(ApiResponse.success(reminders));
    }

    @GetMapping("/api/pets/{petId}/reminders/upcoming")
    public ResponseEntity<ApiResponse<List<HealthReminderResponse>>> getUpcomingReminders(
            @PathVariable String petId, Authentication auth) {
        String userId = auth.getName();
        List<HealthReminderResponse> reminders = healthReminderService.getUpcomingReminders(petId, userId);
        return ResponseEntity.ok(ApiResponse.success(reminders));
    }

    @PostMapping("/api/pets/{petId}/reminders")
    public ResponseEntity<ApiResponse<HealthReminderResponse>> createReminder(
            @PathVariable String petId,
            @RequestBody HealthReminderRequest req,
            Authentication auth) {
        String userId = auth.getName();
        HealthReminderResponse reminder = healthReminderService.createReminder(petId, userId, req);
        return ResponseEntity.ok(ApiResponse.success(reminder));
    }

    @PutMapping("/api/reminders/{id}")
    public ResponseEntity<ApiResponse<HealthReminderResponse>> updateReminder(
            @PathVariable String id,
            @RequestBody HealthReminderRequest req,
            Authentication auth) {
        String userId = auth.getName();
        HealthReminderResponse reminder = healthReminderService.updateReminder(id, userId, req);
        return ResponseEntity.ok(ApiResponse.success(reminder));
    }

    @DeleteMapping("/api/reminders/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteReminder(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        healthReminderService.deleteReminder(id, userId);
        return ResponseEntity.ok(ApiResponse.success("删除成功", null));
    }
}
