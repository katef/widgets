/* $Id: abbrtitle.js 317 2012-02-22 18:12:31Z kate $ */

var Abbrtitle = new (function () {

	/* TODO: generate by sed - and also output a .dtd of &xyz; entities */
	var abbrs = [
		[ 'API',  'Application Program Interface' ],
		[ 'CLI',  'Command Line Interface'        ],
		[ 'CSS3', 'Cascading Style Sheets'        ],
		[ 'CSS',  'Cascading Style Sheets'        ],
		[ 'DRA',  'Defence Research Agency'       ],
		[ 'IRL',  'In Real Life'                  ],
		[ 'EOF',  'Embedded OpenType'             ],
		[ 'GUI',  'Graphical User Interface'      ],
		[ 'I/O',  'Input/Output'                  ],
		[ 'IOS',  'Internetwork Operating System' ],
		[ 'ISO',  'International Organization for Standardization' ],
		[ 'KVM',  'Kernel-based Virtual Machine'  ],
		[ 'MPLS', 'Multiprotocol Label Switching' ],
		[ 'ODF',  'Open Document Format'          ],
		[ 'ODT',  'Open Document format'          ],
		[ 'OS',   'Operating System'              ],
		[ 'OSPF', 'Open Shortest Path First'      ],
		[ 'OTF',  'OpenType Font'                 ],
		[ 'PDF',  'Portable Document Format'      ],
		[ 'SVG',  'Scalable Vector Graphics'      ],
		[ 'FSM',  'Finite State Machine'          ],
		[ 'TTF',  'TrueType Font'                 ]
	];

	function settitle(a) { 
		for (var i in abbrs) {
			if (a.innerHTML == abbrs[i][0]) {
				a.setAttribute('title', abbrs[i][1]);
			}
		}
	}

	this.init = function (root) {
		var a;

		a = root.getElementsByTagName('abbr');
		for (var i = 0; i < a.length; i++) {
			if (!a[i].getAttribute('title')) {
				settitle(a[i]);
			}
		}

		a = root.getElementsByTagName('acronym');
		for (var i = 0; i < a.length; i++) {
			if (!a[i].getAttribute('title')) {
				settitle(a[i]);
			}
		}
	}

});

