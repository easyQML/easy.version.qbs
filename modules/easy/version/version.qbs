// SPDX-FileCopyrightText: © 2024 Serhii “GooRoo” Olendarenko
//
// SPDX-License-Identifier: BSD-3-Clause

import qbs.File
import qbs.FileInfo
import qbs.TextFile

Module {
	additionalProductTypes: ['text']

	Depends { name: 'cpp' }
	Depends { name: 'texttemplate' }

	version: versionProbe.version

	readonly property var parsedVersion: {
		// Match a version in one of the following formats (just some examples):
		// - 1.2  (equivalent of 1.2.0)
		// - 1.2.3
		// - 1.2α1
		// - 1.2.3α2
		// - 100.200.300ω42
		//
		// α - alpha, β - beta, ω - release candidate
		const regex = /^((\d+\.\d+)(?:\.\d+)?)(([αβω])(\d+))?$/
		const matchedVersion = version.match(regex)

		if (!matchedVersion) {
			console.error('Version cannot be parsed')
		}

		return {
			fullVersion: matchedVersion[0],
			threeDigits: (matchedVersion[1] === matchedVersion[2])? matchedVersion[2] + '.0' : matchedVersion[1],
			twoDigits: matchedVersion[2],
			variant: matchedVersion[3],
			variantLetter: matchedVersion[4],
			variantNumber: matchedVersion[5],
		}
	}

	readonly property string threeDigits: parsedVersion.threeDigits
	readonly property string twoDigits: parsedVersion.twoDigits
	readonly property string variant: parsedVersion.variant
	readonly property string variantLetter: parsedVersion.variantLetter
	readonly property string variantNumber: parsedVersion.variantNumber
	readonly property string primitive: version.replace('α', 'a').replace('β', 'b').replace('ω', 'rc')

	Group {
		prefix: project.sourceDirectory + '/'
		files: ['VERSION.txt']
		fileTags: ['version']
	}

	cpp.includePaths: [exportingProduct.buildDirectory]

	Probe {
		id: versionProbe
		property string version
		property path versionFile: FileInfo.joinPaths(project.sourceDirectory, 'VERSION.txt')

		// this property triggers re-evaluation of the probe
		readonly property int _versionFileLastModified: versionFile ? File.lastModified(versionFile) : 0

		configure: {
			var file = new TextFile(versionFile)
			var content = file.readAll().trim()
			file.close()
			version = content
			found = true
		}
	}

	texttemplate.dict: ({
		version: version,
		twoDigits: twoDigits,
		threeDigits: threeDigits,
		variant: variant,
		variantLetter: variantLetter,
		variantNumber: variantNumber,
	})
}
