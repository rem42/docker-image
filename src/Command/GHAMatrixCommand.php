<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Twig\Environment;

class GHAMatrixCommand extends Command
{
    protected static $defaultName = 'app:gha:matrix';

    public function __construct(
        protected string $configFile,
        protected string $renderDir
    ) {
        parent::__construct();
    }


    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $configs = json_decode(file_get_contents($this->configFile), true, 512, JSON_THROW_ON_ERROR);

        foreach ($configs['docker']['images'] as $image) {
            $matrix = [
                'versions' => $image['versions'],
                'variants' => $image['variants'],
            ];
            file_put_contents($this->renderDir.'/matrix.json', json_encode($matrix, JSON_THROW_ON_ERROR));
        }

        return Command::SUCCESS;
    }
}
