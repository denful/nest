// @ts-check
import { defineConfig, fontProviders } from 'astro/config';
import starlight from '@astrojs/starlight';

import mermaid from 'astro-mermaid';
import catppuccin from "@catppuccin/starlight";

// https://astro.build/config
export default defineConfig({
	experimental: {
		fonts: [
			{
				provider: fontProviders.google(),
				name: "Victor Mono",
				cssVariable: "--font-victor-mono",
			},
			{
				provider: fontProviders.google(),
				name: "JetBrains Mono",
				cssVariable: "--font-jetbrains-mono",
			},
		],
	},
	integrations: [
		mermaid({
			theme: 'forest',
			autoTheme: true
		}),
		starlight({
			title: 'nest',
			social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/vic/nest' }
      ],
			sidebar: [
				{
					label: 'Nest',
					items: [
						{ label: 'Overview', slug: 'overview' },
					],
				},
				{
					label: 'Understand',
					items: [
						{ label: 'Traits as Classification', slug: 'explanation/traits' },
						{ label: 'DOM as Infra Structure', slug: 'explanation/dom' },
						{ label: 'CSS as Configuration', slug: 'explanation/css-for-nix' },
						{ label: 'The Configuration Pipeline', slug: 'explanation/pipeline' },
					],
				},
				{
					label: 'Guides',
					items: [
						{ label: 'Getting Started', slug: 'guides/getting-started' },
						{ label: 'Multi-Environment Fleet', slug: 'guides/fleet' },
						{ label: 'Integrations Templates', slug: 'guides/integrations' },
						{ label: 'Beyond NixOS Templates', slug: 'guides/beyond-nixos' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'Selectors', slug: 'reference/selectors' },
						{ label: 'Traits', slug: 'reference/traits' },
						{ label: 'Rules', slug: 'reference/rules' },
						{ label: 'Select API', slug: 'reference/select' },
						{ label: 'CSS Syntax', slug: 'reference/css-syntax' },
						{ label: 'flakeModule', slug: 'reference/flake-module' },
					],
				},
			],
			components: {
				Head: './src/components/Head.astro',
				Sidebar: './src/components/Sidebar.astro',
				Footer: './src/components/Footer.astro',
				SocialIcons: './src/components/SocialIcons.astro',
				PageSidebar: './src/components/PageSidebar.astro',
				Hero: './src/components/Hero.astro',
			},
			plugins: [
				catppuccin({
					dark: { flavor: "macchiato", accent: "mauve" },
					light: { flavor: "latte", accent: "mauve" },
				}),
			],
			editLink: {
				baseUrl: 'https://github.com/vic/nest/edit/main/docs/',
			},
			customCss: [
				'./src/styles/custom.css'
			],
		}),
	],
});
