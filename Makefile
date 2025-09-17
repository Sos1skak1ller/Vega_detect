# Makefile для автоматической настройки виртуальной среды и Jupyter kernel
# Использование: make activate, make kernel, make install, make clean

.PHONY: help activate kernel install clean test

# Переменные
VENV_DIR = .venv
PYTHON = python3
PIP = $(VENV_DIR)/bin/pip
PYTHON_VENV = $(VENV_DIR)/bin/python
KERNEL_NAME = vega-detect-env

# Цвета для вывода
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## Показать справку
	@echo "$(GREEN)Доступные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

activate: ## Создать и активировать виртуальную среду
	@echo "$(GREEN)Создание виртуальной среды...$(NC)"
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "$(GREEN)Виртуальная среда создана в $(VENV_DIR)/$(NC)"
	@echo "$(YELLOW)Для активации выполните: source $(VENV_DIR)/bin/activate$(NC)"

install: $(VENV_DIR) ## Установить все зависимости
	@echo "$(GREEN)Установка зависимостей...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install jupyter notebook ipykernel
	$(PIP) install opencv-python-headless
	$(PIP) install numpy
	$(PIP) install matplotlib
	$(PIP) install scipy
	$(PIP) install scikit-image
	$(PIP) install pillow
	@echo "$(GREEN)Все зависимости установлены!$(NC)"

kernel: $(VENV_DIR) ## Создать Jupyter kernel
	@echo "$(GREEN)Создание Jupyter kernel...$(NC)"
	$(PYTHON_VENV) -m ipykernel install --user --name=$(KERNEL_NAME) --display-name="Vega Detect Environment"
	@echo "$(GREEN)Kernel '$(KERNEL_NAME)' создан!$(NC)"
	@echo "$(YELLOW)Теперь выберите этот kernel в Jupyter Notebook$(NC)"

setup: activate install kernel ## Полная настройка (создать venv + установить + kernel)
	@echo "$(GREEN)Полная настройка завершена!$(NC)"
	@echo "$(YELLOW)Для активации: source $(VENV_DIR)/bin/activate$(NC)"
	@echo "$(YELLOW)Для запуска Jupyter: jupyter notebook$(NC)"

test: $(VENV_DIR) ## Тестировать установку
	@echo "$(GREEN)Тестирование установки...$(NC)"
	$(PYTHON_VENV) -c "import cv2, numpy, jupyter; print('✓ OpenCV:', cv2.__version__); print('✓ NumPy:', numpy.__version__); print('✓ Все модули импортированы успешно!')"

clean: ## Удалить виртуальную среду и kernel
	@echo "$(RED)Удаление виртуальной среды...$(NC)"
	rm -rf $(VENV_DIR)
	@echo "$(RED)Удаление Jupyter kernel...$(NC)"
	jupyter kernelspec remove $(KERNEL_NAME) -y 2>/dev/null || true
	@echo "$(GREEN)Очистка завершена!$(NC)"

# Проверка существования виртуальной среды
$(VENV_DIR):
	@echo "$(RED)Виртуальная среда не найдена!$(NC)"
	@echo "$(YELLOW)Выполните: make activate$(NC)"
	@exit 1

# Информация о системе
info: ## Показать информацию о системе
	@echo "$(GREEN)Информация о системе:$(NC)"
	@echo "Python: $(shell $(PYTHON) --version)"
	@echo "Pip: $(shell $(PYTHON) -m pip --version)"
	@echo "Jupyter: $(shell jupyter --version 2>/dev/null || echo 'Не установлен')"
	@echo "OpenCV: $(shell $(PYTHON) -c 'import cv2; print(cv2.__version__)' 2>/dev/null || echo 'Не установлен')"

# Запуск Jupyter
jupyter: $(VENV_DIR) ## Запустить Jupyter Notebook
	@echo "$(GREEN)Запуск Jupyter Notebook...$(NC)"
	@echo "$(YELLOW)Kernel: $(KERNEL_NAME)$(NC)"
	$(VENV_DIR)/bin/jupyter notebook

# Запуск JupyterLab
jupyterlab: $(VENV_DIR) ## Запустить JupyterLab
	@echo "$(GREEN)Запуск JupyterLab...$(NC)"
	@echo "$(YELLOW)Kernel: $(KERNEL_NAME)$(NC)"
	$(VENV_DIR)/bin/jupyter lab
