Contributing to QuarkBIOS
Thank you for your interest in contributing to QuarkBIOS!
This project is an experimental, educational BIOS and bootloader for x86/x86‑64 platforms. Contributions help improve documentation, code quality, and feature development.

📋 Contribution Guidelines
1. Fork and Branch
Fork the repository to your own GitHub account.

Create a new branch for your changes:
```
bash
git checkout -b feature/my-feature
```
2. Code Style
Use NASM syntax for assembly code.

Keep comments clear and concise.

English comments are preferred for clarity and sharing.

Maintain reproducibility: document build steps and avoid “magic” solutions.

3. Commit Messages
Write descriptive commit messages:

Use the imperative mood (“Add support for INT 13h”).

Reference issues if applicable (Fixes #42).

4. Testing
Test changes in QEMU or another emulator before submitting.

Ensure no warnings or errors during assembly (nasm -f bin).

Verify that the BIOS boots and displays correctly without corrupted characters.

5. Documentation
Update docs/ if your change affects architecture, design, or usage.

Add examples or diagrams where helpful.

Keep README and roadmap consistent with new features.

6. Pull Requests
Open a Pull Request against the main branch.

Provide a clear description of:

What the change does

Why it is needed

How it was tested

Be ready to discuss and revise based on feedback.

🛠️ Types of Contributions
Code: new BIOS features, bug fixes, optimizations.

Documentation: tutorials, design notes, diagrams.

Testing: reporting bugs, reproducing issues, suggesting improvements.

Tools: scripts for building, running, or debugging.

⚖️ License
By contributing, you agree that your contributions will be licensed under the same license as the project: GPLv3.

🤝 Community Standards
Be respectful and constructive in discussions.

Focus on technical clarity and reproducibility.

Contributions should align with the project’s educational and research goals.
