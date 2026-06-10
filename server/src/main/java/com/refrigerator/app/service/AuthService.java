package com.refrigerator.app.service;

import com.refrigerator.app.dto.AuthResponseDto;
import com.refrigerator.app.dto.LoginRequestDto;
import com.refrigerator.app.dto.RegisterRequestDto;
import com.refrigerator.app.entity.User;
import com.refrigerator.app.repository.UserRepository;
import com.refrigerator.app.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    /**
     * 회원가입
     */
    @Transactional
    public AuthResponseDto register(RegisterRequestDto dto) {
        if (userRepository.existsByLoginId(dto.getLoginId())) {
            throw new RuntimeException("이미 사용 중인 아이디입니다.");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("이미 사용 중인 닉네임입니다.");
        }
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("이미 사용 중인 이메일입니다.");
        }

        User user = User.builder()
                .loginId(dto.getLoginId())
                .username(dto.getUsername())
                .password(passwordEncoder.encode(dto.getPassword()))
                .email(dto.getEmail())
                .phone(dto.getPhone())
                .build();

        user = userRepository.save(user);
        String token = jwtUtil.generateToken(user.getUserId(), user.getEmail());

        return AuthResponseDto.builder()
                .userId(user.getUserId())
                .loginId(user.getLoginId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(token)
                .build();
    }

    /**
     * 프로필 수정
     */
    @Transactional
    public AuthResponseDto updateProfile(Long userId, com.refrigerator.app.dto.UpdateProfileRequestDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        if (dto.getUsername() != null && !dto.getUsername().isBlank()) {
            user.setUsername(dto.getUsername());
        }
        if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
            user.setEmail(dto.getEmail());
        }
        if (dto.getPhone() != null) {
            user.setPhone(dto.getPhone());
        }
        if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        user = userRepository.save(user);
        String token = jwtUtil.generateToken(user.getUserId(), user.getEmail());

        return AuthResponseDto.builder()
                .userId(user.getUserId())
                .loginId(user.getLoginId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(token)
                .build();
    }

    /**
     * 로그인
     */
    @Transactional(readOnly = true)
    public AuthResponseDto login(LoginRequestDto dto) {
        User user = userRepository.findByLoginId(dto.getLoginId())
                .orElseThrow(() -> new RuntimeException("아이디 또는 비밀번호가 올바르지 않습니다."));

        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new RuntimeException("아이디 또는 비밀번호가 올바르지 않습니다.");
        }

        String token = jwtUtil.generateToken(user.getUserId(), user.getEmail());

        return AuthResponseDto.builder()
                .userId(user.getUserId())
                .loginId(user.getLoginId())
                .username(user.getUsername())
                .email(user.getEmail())
                .token(token)
                .build();
    }
}
