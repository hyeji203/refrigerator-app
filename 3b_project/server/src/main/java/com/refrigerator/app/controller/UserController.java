package com.refrigerator.app.controller;

import com.refrigerator.app.dto.AuthResponseDto;
import com.refrigerator.app.dto.UpdateProfileRequestDto;
import com.refrigerator.app.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final AuthService authService;

    public UserController(AuthService authService) {
        this.authService = authService;
    }

    @PatchMapping("/{userId}")
    public ResponseEntity<?> updateProfile(@PathVariable Long userId,
                                           @RequestBody UpdateProfileRequestDto dto) {
        try {
            AuthResponseDto response = authService.updateProfile(userId, dto);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}
