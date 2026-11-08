# Agent Guidelines

<!-- Do not restructure or delete sections. Update individual values in-place when they change. -->

## Core Principles

- **Do NOT maintain backward compatibility** unless explicitly requested. Break things boldly.
- **Keep this file under 20-30 lines of instructions.** Every line competes for the agent's limited context budget (~150-200 total).

---

## Project Overview

This workspace uses **self-hosted** Supermemory (API v5) at `http://localhost:6767`. Set `baseURL` / `SUPERMEMORY_API_URL` to that origin — do not use `api.supermemory.ai`. Default namespace: `user_hiroqn`.

