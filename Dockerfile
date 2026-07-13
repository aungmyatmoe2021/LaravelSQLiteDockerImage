# 1. Use the official Composer image for the binary
FROM composer:latest AS composer

# 2. Use my target PHP Image
FROM php:8.3-fpm

# 3. Copy the Composer binary from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# 4. Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev libzip-dev zip unzip git

# 5. Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 6. ADDED: Set Composer global install path ---
ENV COMPOSER_HOME=/usr/local/composer
ENV PATH=$PATH:$COMPOSER_HOME/vendor/bin

# 7. Install Laravel installer globally
RUN composer global require laravel/installer

# 8. Mark Working Directory
WORKDIR /var/www

# 9. Copy existing application
COPY . .

# 10. Create the directories if they are missing
RUN mkdir -p /var/www/storage /var/www/bootstrap/cache

# 11. Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# 12. Copy Composer files and install dependencies
COPY src/composer.json src/composer.lock ./
RUN composer install --no-scripts