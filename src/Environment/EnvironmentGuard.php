<?php

declare(strict_types=1);

namespace Letsfix\Tickets\Environment;

final class EnvironmentGuard
{
    public static function assertNonProduction(?string $environment): void
    {
        $normalizedEnvironment = strtolower(trim($environment ?? ''));

        if (!in_array($normalizedEnvironment, ['local', 'staging'], true)) {
            throw new UnsafeEnvironmentException(
                'Lifecycle operations require an explicitly identified local or staging environment.'
            );
        }
    }
}