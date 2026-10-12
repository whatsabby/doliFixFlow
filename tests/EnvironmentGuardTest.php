<?php

declare(strict_types=1);

namespace Letsfix\Tickets\Tests;

use Letsfix\Tickets\Environment\EnvironmentGuard;
use Letsfix\Tickets\Environment\UnsafeEnvironmentException;
use PHPUnit\Framework\TestCase;

final class EnvironmentGuardTest extends TestCase
{
    /**
     * @dataProvider allowedEnvironments
     */
    public function testItAllowsOnlyIdentifiedNonProductionEnvironments(string $environment): void
    {
        $this->expectNotToPerformAssertions();

        EnvironmentGuard::assertNonProduction($environment);
    }

    public static function allowedEnvironments(): array
    {
        return [
            'local development' => ['local'],
            'staging' => ['staging'],
        ];
    }

    /**
     * @dataProvider blockedEnvironments
     */
    public function testItFailsClosedForProductionMissingOrUnknownEnvironments(?string $environment): void
    {
        $this->expectException(UnsafeEnvironmentException::class);

        EnvironmentGuard::assertNonProduction($environment);
    }

    public static function blockedEnvironments(): array
    {
        return [
            'production' => ['production'],
            'missing' => [null],
            'empty' => [''],
            'unknown' => ['preproduction'],
        ];
    }
}